#Include "GTPC300P.ch"//***************
#include 'totvs.ch'
#INCLUDE "FWMVCDEF.CH"





/*/{Protheus.doc} GTPC300U
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/

Function GTPC300U()
Local lMonitor	:= GC300GetMVC('IsActive')

If lMonitor
	
	FWExecView( "Reclamações", 'VIEWDEF.GTPC300U', MODEL_OPERATION_UPDATE, , { || .T. } ) //"Reclamações"
	
Else
	FwAlertHelp("Reclamações",STR0006) //"Esta rotina só funciona com monitor ativo" //"Reclamações"
Endif
	
return



/*/{Protheus.doc} Modeldef
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function Modeldef()

Local oStrCab  := FWFormModelStruct():New()
Local oStrGrd  := FWFormStruct(1,"H7T")
Local bPosValid := {|oModel|PosValid(oModel)}
Local oModel   := Nil

StructModel(oStrCab,oStrGrd)

oModel := MPFormModel():New('GTPC300U',/*bPreValid*/, bPosValid, , /*bCancel*/)

oModel:AddFields("H7TMASTER", , oStrCab,,,{||})
oModel:AddGrid("H7TDETAIL", "H7TMASTER", oStrGrd, , , , , )

oModel:SetRelation( 'H7TDETAIL', { { 'H7T_FILIAL', 'xFilial( "GYN" )' }, { 'H7T_VIAGEM', 'CODVIAG' } }, H7T->(IndexKey(3)))
oModel:GetModel("H7TDETAIL"):SetLoadFilter(, " H7T_STATUS <> 'E' ")

oModel:GetModel("H7TMASTER"):SetDescription(STR0007) //"Viagem"
oModel:GetModel("H7TDETAIL"):SetDescription("Reclamações") //"Reclamações"

oModel:SetDescription("Reclamações de viagem") //"Reclamações de viagem"
oModel:SetPrimaryKey({})

Return(oModel)







/*/{Protheus.doc} PosValid
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function PosValid(oModel)
Local oMdl300 
Local oMdl	      := oModel:GetModel()
Local oMdlGrd	  := oMdl:GetModel('H7TDETAIL')
Local oMldMonitor := GC300GetMVC('M')
Local oViewMonitor:= GC300GetMVC('V')
Local oMdlGYN	  := oMldMonitor:GetModel( 'GYNDETAIL' )
Local nI		  := 0
Local nOpc        := oMdl:GetOperation()
Local lRet        := .T.
Local cStatus     := ""
Local lUpdGYN	  := !oMdlGYN:CanUpdateLine()
Local cGYN_STSOCR := ""
Local cStatusLeg  := ""

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)
	If oMdlGrd:IsDeleted()
		oMdlGrd:DeleteLine()
	EndIf
Next

oMdl300 := FwLoadModel("GTPA300")

//Realizar a modificação da viagem posicionada para A ou E
If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE 
	If GYN->(DbSeek(xFilial("GYN") + oMdlGrd:GetValue("H7T_VIAGEM")))
		
		If lRet
			oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
		
			IF oMdl300:Activate()
				If !(IsInCallstack("AltFcOcorn")) .Or. Empty(cStatus) .Or.  !(IsInCallstack("GTPC300V"))
					cStatus := 'A'
				EndIf
				
				oMdl300:GetModel("GYNMASTER"):LoadValue("GYN_STSH7T",cStatus)
				
				If lRet := oMdl300:VldData()
					oMdl300:CommitData()
				EndIf
				oMdl300:DeActivate()
			EndIf
		EndIf
	EndIf
EndIf
If lRet
	oMdlGYN:SetNoUpdateLine(.F.)
	cGYN_STSOCR := oMdlGYN:GetValue("GYN_STSOCR")
	cStatusLeg	:= G300Status(cStatus,cGYN_STSOCR) //cStatus=GYN_STSH7T,cGYN_STSOCR=GYN_STSOCR

	If oMdlGYN:SeekLine({{'GYN_CODIGO',oMdlGrd:GetValue("H7T_VIAGEM")}})
		oMdlGYN:SetValue("GYN_STSLEG",cStatusLeg) 
	EndIf
	oMdlGYN:SetNoUpdateLine(lUpdGYN)
	oViewMonitor:Refresh("GYNDETAIL")
EndIf
	
Return lRet




/*/{Protheus.doc} StructModel
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function StructModel(oStrCab,oStrGrd)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}

oStrCab:AddField(STR0011,;				// 	[01]  C   Titulo do campo //"Cod. Viaj"
					STR0012,;			// 	[02]  C   ToolTip do campo //"Codigo Viagem"
					"CODVIAG",;				// 	[03]  C   Id do Field
					"C",;						// 	[04]  C   Tipo do campo
					TamSx3('GYN_CODIGO')[1],;	// 	[05]  N   Tamanho do campo
					0,;						// 	[06]  N   Decimal do campo
					Nil,;						// 	[07]  B   Code-block de validação do campo
					Nil,;						// 	[08]  B   Code-block de validação When do campo
					Nil,;						//	[09]  A   Lista de valores permitido do campo
					.F.,;						//	[10]  L   Indica se o campo tem preenchimento obrigatório
					Nil,;						//	[11]  B   Code-block de inicializacao do campo
					.F.,;						//	[12]  L   Indica se trata-se de um campo chave
					.F.,;						//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)						// 	[14]  L   Indica se o campo é virtual
					
oStrCab:SetProperty('CODVIAG', MODEL_FIELD_INIT	, bInit )

oStrGrd:AddTrigger('H7T_VIAGEM'	,'H7T_VIAGEM'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('H7T_TPOCOR'	,'H7T_TPOCOR'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('H7T_LOCORI'	,'H7T_LOCORI'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('H7T_LOCDES'	,'H7T_LOCDES'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('H7T_CODVEI'	,'H7T_CODVEI'	,{||.T.}, bTrig)
oStrGrd:AddTrigger('H7T_COLCOD'	,'H7T_COLCOD'	,{||.T.}, bTrig)


oStrGrd:SetProperty('H7T_VIAGEM', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_DATA'  , MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_HORA'  , MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_DTVIAG', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_LOCORI', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_NMLOCA', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_LOCDES', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_NMDEST', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_USRPRT', MODEL_FIELD_INIT	, bInit )
oStrGrd:SetProperty('H7T_NMTPOC', MODEL_FIELD_INIT	, bInit )




Return




/*/{Protheus.doc} FieldTrigger
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel	:= oMdl:GetModel()

    Do Case
        Case cField == 'H7T_TPOCOR'
            uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_TPOCOR"),"G6Q_DESCRI")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_NMTPOC', uRet)
            
            If oModel:GetOperation()==3 .or. oModel:GetOperation()==4
                oModel:GetModel("H7TDETAIL"):SetValue('H7T_DATA',   dDataBase)
                oModel:GetModel("H7TDETAIL"):SetValue('H7T_HORA',   Time())
            EndIf

            //Ajusta SLA
            If FwAlertYesNo("Deseja recalcular o prazo final com o novo SLA ?", "Atenção") // "Deseja recalcular o prazo final com o novo SLA ?","Atenção"
                uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_TPOCOR"),"G6Q_TIPOOC")
                iF ValType(uRet) =="C" .And. uRet$"2|3"
                    uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_TPOCOR"),"G6Q_SLAOCO")
                    oModel:GetModel("H7TDETAIL"):SetValue('H7T_SLAOCO', uRet)
                    iF ValType(uRet) =="N" .And. uRet>0
                        oModel:GetModel("H7TDETAIL"):SetValue('H7T_SLAFIM', DaySum(dDatabase, uRet)) 
                    EndIf
                EndIf
            EndIf

        Case cField == 'H7T_VIAGEM'
            uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_VIAGEM"),"GYN_DTINI")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_DTVIAG',uRet)
            uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_VIAGEM"),"GYN_LOCORI")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_LOCORI',uRet)
            uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_VIAGEM"),"GYN_LOCDES")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_LOCDES',uRet)


        Case cField == 'H7T_LOCORI'
            uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_LOCORI"),"GI1_DESCRI")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_NMLOCA',uRet)
            
        Case cField == 'H7T_LOCDES'
            uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_LOCDES"),"GI1_DESCRI")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_NMDEST',uRet)

        Case cField == 'H7T_CODVEI'
            uRet := POSICIONE("DA3",1,XFILIAL("DA3") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_CODVEI"),"DA3_DESC")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_DCODVE',uRet)
            uRet := POSICIONE("DA3",1,XFILIAL("DA3") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_CODVEI"),"DA3_PLACA")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_EPPLAC',uRet)
            uRet := POSICIONE("DA3",1,XFILIAL("DA3") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_CODVEI"),"DA3_ESTPLA")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_EPESTA',uRet)
        
        Case cField == "H7T_COLCOD"
            uRet := POSICIONE("GYG",1,XFILIAL("GYG") + oModel:GetModel("H7TDETAIL"):GetValue("H7T_COLCOD"),"GYG_NOME")
            oModel:GetModel("H7TDETAIL"):SetValue('H7T_COLNOM',uRet)

    EndCase

Return uVal




/*/{Protheus.doc} FieldInit
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet		  := uVal
Local oMldMonitor := GC300GetMVC('M')
Local oMdlGYN	  := oMldMonitor:GetModel( 'GYNDETAIL' )

Do Case 
	Case cField == 'CODVIAG'
		uRet := oMdlGYN:GetValue("GYN_CODIGO")
	Case cField == 'H7T_DATA'
		uRet := dDataBase
	Case cField == 'H7T_HORA'
		uRet := Time()
	Case cField == 'H7T_VIAGEM'
		uRet := oMdlGYN:GetValue("GYN_CODIGO")
	Case cField == 'H7T_DTVIAG'
		 uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oMdlGYN:GetValue("GYN_CODIGO"),"GYN_DTINI")
	Case cField == 'H7T_LOCORI'
		 uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oMdlGYN:GetValue("GYN_CODIGO"),"GYN_LOCORI")
	Case cField == 'H7T_LOCDES'
		 uRet := POSICIONE("GYN",1,XFILIAL("GYN") + oMdlGYN:GetValue("GYN_CODIGO"),"GYN_LOCDES")
	Case cField == 'H7T_NMLOCA'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oMdlGYN:GetValue("GYN_LOCORI"),"GI1_DESCRI")
	Case cField == 'H7T_NMDEST'
		uRet := POSICIONE("GI1",1,XFILIAL("GI1") + oMdlGYN:GetValue("GYN_LOCDES"),"GI1_DESCRI")
	Case cField == 'H7T_USRPRT'
		uRet := LogUserName()
	Case cField == 'H7T_NMTPOC'
		uRet := POSICIONE("G6Q",1,XFILIAL("G6Q") + H7T->H7T_TPOCOR,"G6Q_DESCRI")


EndCase

Return uRet




/*/{Protheus.doc} Viewdef
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function Viewdef()

Local oStrCab  := FWFormViewStruct():New()
Local oStrGrd  := FWFormStruct(2,"H7T")
Local oModel   := ModelDef()
Local oView    := Nil

StructView(oStrCab,oStrGrd)

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VW_H7TMASTER', oStrCab, 'H7TMASTER')
oView:AddGrid('VW_H7TDETAIL', oStrGrd, 'H7TDETAIL')

oView:CreateHorizontalBox('CABEC', 30)
oView:CreateHorizontalBox('CORPO', 70)

oView:SetOwnerView('VW_H7TMASTER', 'CABEC')
oView:SetOwnerView('VW_H7TDETAIL', 'CORPO')

oView:SetViewProperty("H7TDETAIL", "GRIDSEEK"	, {.T.})
oView:SetViewProperty("H7TDETAIL", "GRIDFILTER"	, {.T.})

oView:EnableTitleView('VW_H7TMASTER')
oView:EnableTitleView('VW_H7TDETAIL')

oView:AddUserButton("Reabrir"	,"",{|oView| AlterReclama("A",oView) } ,,VK_F6) //"Reabrir"
oView:AddUserButton("Encerrar"	,"",{|oView| AlterReclama("E",oView) } ,,VK_F8) //"Encerrar"

Return(oView)





/*/{Protheus.doc} StructView
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
Static Function StructView(oStrCab,oStrGrd)

Local aFields := {}
Local cFields := ""
Local nI      := 0

oStrCab:AddField("CODVIAG",;			// [01]  C   Nome do Campo
			"01",;						// [02]  C   Ordem
			STR0011,;				// [03]  C   Titulo do campo //"Cod. Viaj"
			STR0012,;			// [04]  C   Descricao do campo //"Codigo Viagem"
			Nil,;						// [05]  A   Array com Help // "Selecionar"
			"GET",;						// [06]  C   Tipo do campo
			"@C",;						// [07]  C   Picture
			NIL,;						// [08]  B   Bloco de Picture Var
			"",;						// [09]  C   Consulta F3
			.T.,;						// [10]  L   Indica se o campo é alteravel
			NIL,;						// [11]  C   Pasta do campo
			"",;						// [12]  C   Agrupamento do campo
			NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
			NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
			NIL,;						// [15]  C   Inicializador de Browse
			.T.,;						// [16]  L   Indica se o campo é virtual
			NIL,;						// [17]  C   Picture Variavel
			.F.)						// [18]  L   Indica pulo de linha após o campo

If !FwIsInCallStack('AlterReclama')

	aFields := aClone(oStrGrd:GetFields())
		
	cFields := "H7T_FILIAL|H7T_CODIGO|H7T_USRPRT|H7T_STATUS"

	For nI := 1 to Len(aFields)
		
		If ( (aFields[nI,1] $ cFields) )
		
			If ( oStrGrd:HasField(aFields[nI,1]) )
				oStrGrd:RemoveField(aFields[nI,1])
			EndIf
				
		EndIf	
		
	Next nI

EndIf 

Return




/*/{Protheus.doc} AlterReclama
@author Yuri Porto
@since 03/09/2024
@version 1.0
/*/
static Function AlterReclama(cAlteraFc, oView)

Local oMldMonitor := GC300GetMVC('M')
Local oViewMonitor:= GC300GetMVC('V')
Local oMdlGrd	  := oView:GetModel('H7TDETAIL')
Local oMdlCabecH7T:= FwLoadModel("GTPC300U")
Local oMdlH7T     := oMdlCabecH7T:GetModel("H7TDETAIL")
Local cStatus     := ""
Local cStatusLeg  := ""
Local cViagem     := ""
Local nI          := 0
Local lRet        := .T.
Local oMdlGYN	  := oMldMonitor:GetModel( 'GYNDETAIL' )
Local lUpdGYN	  := !oMdlGYN:CanUpdateLine()
Local cGYN_STSOCR := ""

H7T->(DbSetOrder(1))

For nI := 1 To oMdlGrd:Length()
	oMdlGrd:GoLine(nI)

	If H7T->(DbSeek( xFilial("H7T") + oMdlGrd:GetValue("H7T_CODIGO")))
		cViagem := oMdlGrd:GetValue("H7T_VIAGEM")
		If POSICIONE("GYN",1,XFILIAL("GYN") + cViagem, "GYN_FINAL") != "1"
			oMdlCabecH7T:SetOperation(MODEL_OPERATION_UPDATE)
			IF oMdlCabecH7T:Activate()
				If cAlteraFc == "E"
					cStatus := "E"
				Else
					cStatus := "A"
				EndIf
				
				oMdlH7T:SetValue("H7T_STATUS",cStatus)
				
				If oMdlCabecH77:VldData()
					oMdlCabecH77:CommitData()
				Else
					lRet := .F.
					DisarmTransaction()
				EndIf
			EndIf
			oMdlCabecH77:DeActivate()
		EndIf
	EndIf
Next

If lRet
	oMdlGYN:SetNoUpdateLine(.F.)
	cGYN_STSOCR := oMdlGYN:GetValue("GYN_STSOCR")
	cStatusLeg	:= G300Status(cStatus,cGYN_STSOCR) //cStatus=GYN_STSH7T,cGYN_STSOCR=GYN_STSOCR

	If oMdlGYN:SeekLine({{'GYN_CODIGO',cViagem}})
		lRet := oMdlGYN:SetValue("GYN_STSLEG",cStatusLeg) .AND. oMdlGYN:SetValue("GYN_STSH7T",cStatus)
	EndIf
	oMdlGYN:SetNoUpdateLine(lUpdGYN)
EndIf

If lRet
	oViewMonitor:Refresh("GYNDETAIL")
	If cAlteraFc == 'E'
		MSGINFO( STR0017, 'GTPA300U' )
	Else
		MSGINFO( STR0018, 'GTPA300U' )
	EndIf
Else
	MSGINFO( STR0019, 'GTPA300U' )
EndIf
Return





