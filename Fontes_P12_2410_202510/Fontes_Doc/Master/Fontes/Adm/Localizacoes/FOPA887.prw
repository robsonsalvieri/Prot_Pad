#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FOPA887.CH' 


/*/{Protheus.doc} FOPA887
Fonte de cobros diversos (Padrão)
@author 	jose.gonzalez
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Function FOPA887()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author	 	jose.gonzalez
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function BrowseDef()
Local oBrowse	:= Nil
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FJT')
oBrowse:SetDescription(STR0001)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	jose.gonzalez
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}	
	ADD OPTION aRotina TITLE STR0001 ACTION 'VIEWDEF.FOPA887' 	  OPERATION 3 ACCESS 0 	// 'Incluir'	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author 	jose.gonzalez
@return		oModel objeto del Modelo
@since 		05/04/2021
@version	12.1.27 / Superior
/*/

Static Function ModelDef()
Local oModel	:= FWLoadModel('FINA887')
oModel:GetModel("FJT_MASTER"):GetStruct():SetProperty( '*'  , MODEL_FIELD_OBRIGAT , .F.)
oModel:GetModel("SE1_DETAIL"):GetStruct():SetProperty( '*'  , MODEL_FIELD_OBRIGAT , .F.)

Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización padrón
@return		oView objeto del View
@author 	jose.gonzalez
@since 		21/02/2024
@version	12.2210 / Superior
/*/
Static Function ViewDef()

Local cCampSEL	:= "EL_FILIAL,EL_SERIE,EL_RECIBO,EL_CLIORIG,EL_LOJORIG,EL_NATUREZ,EL_VLMOED1"
Local oModel	:= FWLoadModel('FOPA887') 
Local oView		:= FWFormView():New()
Local oStruSEL	As object
Local nValimp1
local nAlqimp1 
local lDetail := SuperGetMv("MV_EDITLIN",.F.,.F.)

IF SEL->(ColumnPos("EL_SIRECER")) == 0 
	cCampSEL	+= ",EL_TIPO"
EndIF
	oStruSEL	:= FWFormStruct( 2, 'SEL', { | cCampo | !(AllTrim( cCampo ) $ cCampSEL) },,.T.)
	IF (Getsx3Cache( 'EL_VALBASE','X3_TITULO' )) <> NIL .AND. (Getsx3Cache( 'EL_ALIQ','X3_TITULO' )) <> NIL
		nValimp1:= aScan(oStruSEL:afields,{|x|x[1]=="EL_VALBASE"})
		nAlqimp1:= aScan(oStruSEL:afields,{|x|x[1]=="EL_ALIQ"})
		oStruSEL:afields[nValimp1][2] :='12'
		oStruSEL:afields[nAlqimp1][2] :='11'
	EndIF
	oView:SetModel(oModel)
	oView:AddGrid('oStruSEL'  , oStruSEL, 'SEL_DETAIL')
	If lDetail
		oView:SetViewProperty( 'oStruSEL', "ENABLEDGRIDDETAIL", { 50 } )
	EndIf
	oView:CreateHorizontalBox( 'BAIXO', 100)
	oView:SetOwnerView('oStruSEL', 'BAIXO')
  	oView:SetAfterViewActivate({|oView| AfterView(oView)})

Return oView
/*/{Protheus.doc} FIN887FORP
Función para Recuperar el Json que se envia al Front
@author 	jose.gonzalez
@since 		21/02/2024
@version	12.2210 / Superior
/*/
Function FIN887FORP(oModel,lCommit)
Local oModelSEL		:= oModel:GetModel("SEL_DETAIL")
local oMdlSEL :=	oModel:GetModel('SEL_DETAIL'):oFormModelStruct
Local lRet		:= .T.
local nI :=1
local nJ:= 1
local aForpgo := {}
local cCampoTipo :=""
local cCampo := ""
local cProperty :=""
local cValue :=""
Local nValue := 0
Local lValue := .F.

If lCommit
	for nI:= 1 to oModelSEL:Length()
		oModelSEL:GoLine(nI)
		IF oModelSEL:IsDeleted(nI)
			loop
		EndIF
		If oModelSEL:IsEmpty(nI)
			lRet := .F.
			oModel:SetErrorMessage('SEL_DETAIL', '' , 'SEL_DETAIL' , '' , STR0002, STR0003, STR0004)
		EndIf
		Aadd(aForpgo,JsonObject():new())
		for nJ:= 1 to len(oModelSEL:GETSTRUCT():afields)
			cCampo:=oModelSEL:GETSTRUCT():afields[nJ][3]
			cProperty :=lower(Alltrim(substr(cCampo,at("_",cCampo)+1)))
			cCampoTipo := oMdlSEL:GetProperty(cCampo,MODEL_FIELD_TIPO )  
			If cCampoTipo == 'D'
				If !VAZIO(oModelSEL:ADATAMODEL[nI][1][1][nJ])
					cValue := DTOS(oModelSEL:ADATAMODEL[nI][1][1][nJ])
				ELSE
					cValue := ""
				ENDIF
					aForpgo[len(aForpgo)][cProperty]:= cValue
			ElseIF cCampoTipo == 'N'
				If !(oModelSEL:ADATAMODEL[nI][1][1][nJ] == NIL)
					nValue := oModelSEL:ADATAMODEL[nI][1][1][nJ]
					aForpgo[len(aForpgo)][cProperty]:= nValue
				EndIF
			ElseIF cCampoTipo == 'L'
				If !(oModelSEL:ADATAMODEL[nI][1][1][nJ] == NIL)
					lValue := oModelSEL:ADATAMODEL[nI][1][1][nJ]
					aForpgo[len(aForpgo)][cProperty]:= lValue
				EndIF
			Else
				cValue := IIF(oModelSEL:ADATAMODEL[nI][1][1][nJ]!=Nil,oModelSEL:ADATAMODEL[nI][1][1][nJ],"")
				IF !(cCampo == "EL_TIPO" .and. Alltrim(cValue) == "")
					aForpgo[len(aForpgo)][cProperty]:= Alltrim(cValue)
				EndIF
			EndIF
		Next  
	next
EndIf
oJPaymetFo["commit"]:= lCommit
oJPaymetFo["items"]:=aForpgo
Return lRet



Static Function  AfterView(oView)

Local oModel   := oView:GetModel()

Local oMdlSEL As Object 
Local oResponse := JsonObject():New() 

Local aHeader 	:= {}
local nI :=1 
local nj:=1
local apayforms := {}
local atitles:={}
Local aAux:= {}
Local cValue :=""
Local dValue
Local Nvalue := 0
Local cCampo:=""
Local cCampoTipo:=""
local lValue := .F.

apayforms := oJParams['payments']

oMdlSEL := oModel:GetModel('SEL_DETAIL'):oFormModelStruct 

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		For nI := 1 to len(oJParams['coins'])
			If len(oJParams['coins']) > 1 .and. nI > 1
				oModel:GetModel('MOE_DETAIL' ):AddLine()
			EndIF 
			oModel:loadValue('MOE_DETAIL',"MOEDA" 		, alltrim(str(oJParams['coins'][nI]['moneda'])))
			oModel:loadValue('MOE_DETAIL',"TASA" 		, oJParams['coins'][nI]['tasa'] )
		Next
		aHeader := oJParams['header']:GetNames()
		FOR nI := 1 to len(aHeader)
			IF !(("FJT_"+UPPER(aHeader[nI])) $ "FJT_CLIENT")
				If oModel:GetModel('FJT_MASTER'):GETSTRUCT():GetProperty("FJT_"+UPPER(aHeader[nI]),MODEL_FIELD_TIPO ) == 'D'
					oModel:loadValue('FJT_MASTER', "FJT_"+UPPER(aHeader[nI]),STOD(StrTran(oJParams['header'][aHeader[nI]],"-","")))
				Else
					oModel:loadValue('FJT_MASTER', "FJT_"+UPPER(aHeader[nI]),oJParams['header'][aHeader[nI]])	
				EndIf
			ELSE
				aAux := Separa(oJParams['header'][aHeader[nI]],"|")
				oModel:loadValue('FJT_MASTER', "FJT_CLIENT",aAux[1])		
			ENDIF
		NEXT
		oModel:SetValue('FJT_MASTER', "VLDNUMREC" ,.F.)
		if len(apayforms) > 0 
		
			atitles	 := oJParams['payments'][1]:GetNames()
			for  nI := 1 to len(apayforms)
				If len(apayforms) > 1 .and. nI > 1
					oModel:GetModel('SEL_DETAIL' ):AddLine()
				EndIF
				for nJ:=1 to len(atitles)-1
					cValue=""
					dValue := CTOD("")
					Nvalue := 0
					cCampo := "EL_" + Upper(atitles[nJ])
					cCampoTipo := oMdlSEL:GetProperty(cCampo,MODEL_FIELD_TIPO )  
					If cCampoTipo == 'D'
						If !VAZIO(apayforms[nI][atitles[nJ]])
							dValue := STOD(apayforms[nI][atitles[nJ]])		
							oModel:loadValue('SEL_DETAIL',cCampo ,dValue)			
						ENDIF					
					ElseIF cCampoTipo == 'N'
						If !(apayforms[nI][atitles[nJ]] == NIL)
							nValue := apayforms[nI][atitles[nJ]]
							oModel:loadValue('SEL_DETAIL',cCampo ,nValue)
						EndIF
					ElseIF cCampoTipo == 'L'
						If !(apayforms[nI][atitles[nJ]] == NIL)
							lValue := apayforms[nI][atitles[nJ]]
							oModel:loadValue('SEL_DETAIL',cCampo ,	lValue)
						EndIF
					Else	
						cValue := IIF(apayforms[nI][atitles[nJ]]!=Nil,apayforms[nI][atitles[nJ]],"")
						oModel:loadValue('SEL_DETAIL',cCampo ,Alltrim(cValue))
					EndIF
				Next
			Next
			oModel:GetModel('SEL_DETAIL'):GoLine(1)
		Else
			oModel:loadValue('SEL_DETAIL',"EL_EMISSAO",oModel:GetModel("FJT_MASTER"):GetValue("FJT_EMISSA"))
			oModel:loadValue('SEL_DETAIL',"EL_DTVCTO",oModel:GetModel("FJT_MASTER"):GetValue("FJT_EMISSA"))
		EndIf
	ENDiF
oView:Refresh()
RETURN .T.
