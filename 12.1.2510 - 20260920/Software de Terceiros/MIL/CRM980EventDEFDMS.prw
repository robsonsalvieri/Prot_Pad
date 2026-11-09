#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

#INCLUDE "CRM980EventDEFDMS.ch"

static oOFIA402
static oCRMA060

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventDEFDMS
Classe responsável pelo evento das regras de negócio da
localização Padrão DMS.

@type 		Classe
@author 	Squad DMS
@version	12.1.25 / Superior
@since		20/09/2021
/*/
//-------------------------------------------------------------------
Class CRM980EventDEFDMS From FwModelEvent
	DATA lInsert As Logical
	DATA lUpdate As Logical
	DATA lDelete As Logical
	DATA lVeiculo As Logical
	Data lMVMIL0185 as Logical
	Data cMVMIL0187 as Logical
	Data lVCF as Logical

	Method New() CONSTRUCTOR
	
	//-----------------------
	//Metodos utilizados para integração com VEICM560 do DMS
	METHOD VldActivate()
	Method ModelDef(oModel)
	Method ViewDefVCF(oView)	
	//-----------------------

	//---------------------
	// PosValid do Model.
	//---------------------
	//Method ModelPosVld()

	//----------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//---------------------------------------------------------------------
	Method AfterTTS()

	//----------------------------------------------------------------------
	// Bloco com regras de negócio no Tudo OK da Tela. 
	//---------------------------------------------------------------------
	Method ModelPosVld()

EndClass

Method New() Class CRM980EventDEFDMS
	::lMVMIL0185 := GetNewPar("MV_MIL0185",.f.)
	::cMVMIL0187 := GetNewPar("MV_MIL0187", "0")
	::lVCF       := adicionaCamposVCF() 
Return self

/*/{Protheus.doc} VldActivate/*/
//---------------------------------------------------------
Method VldActivate( oModel, cModelId ) Class CRM980EventDEFDMS
	local nOpc  := oModel:GetOperation()

	if ::lVCF
		::lVeiculo := .t.
		::lInsert := (nOpc == MODEL_OPERATION_INSERT)
		::lUpdate := (nOpc == MODEL_OPERATION_UPDATE)
		::lDelete := (nOpc == MODEL_OPERATION_DELETE)		

		self:ModelDef( oModel )
	endif
Return .T.

/*/{Protheus.doc} Modelo de dados ModelDef/*/
//---------------------------------------------------------
Method ModelDef(oModel) Class CRM980EventDEFDMS
    Local oSub := oModel:GetModel("SA1MASTER")
	Local oStruct := oSub:GetStruct()	
	Local aCampos := {"VCF_SCRMED", "VCF_SCRMSC"}
	Local aValues := {}
	Local aTamCpo := {}
    Local nI, nTam, nDec
	local cCampo, cTit, cType, cWhen, cValid
	local lObrig
	local bWhen, bValid, bInit

	//Add campos virtuais à estrutura da "SA1MASTER"
    If ::lVeiculo .and. oSub != Nil
        oStruct:DeActivate() //
        For nI := 1 To Len(aCampos)
            cCampo 	:= aCampos[nI]
            cTit   	:= AllTrim(GetSX3Cache(cCampo, "X3_TITULO"))            
			aTamCpo := FWTamSX3(cCampo)
            nTam 	:= aTamCpo[1]
			nDec	:= aTamCpo[2]
			cType  	:= aTamCpo[3]
            lObrig 	:= CpoObrigat(cCampo)
            aValues	:= StrTokArr2(GetSX3Cache(cCampo, "X3_CBOX"), ";",.t.)
            
            cWhen  	:= GetSX3Cache(cCampo, "X3_WHEN")
			cWhen  	:= SubstMCampo(cWhen) //StrTran(cWhen, "M->VCF_SCRMED", 'FwFldGet("VCF_SCRMED")')
			
			bWhen  	:= IIf(Empty(cWhen), {|| .T.}, &( "{|| " + cWhen + " }" ))
            
            bValid 	:= IIf(Empty(cValid), {|| .T.}, &( "{|| " + cValid + " }" ))
		
			cInit := 'Posicione("VCF",1,xFilial("VCF")+SA1->A1_COD+SA1->A1_LOJA,"'+cCampo+'")'
            bInit := FWBuildFeature( STRUCT_FEATURE_INIPAD, cInit)

			if !oStruct:HasField(cCampo)
				oStruct:AddField(cTit, cTit, cCampo, cType, nTam, nDec, bValid, bWhen, aValues, lObrig, bInit, .F., .F., .T., "")
			endif
        Next nI
        oStruct:Activate()
    EndIf
Return .T.

/*/{Protheus.doc} visao de dados: ViewDefVCF/*/
METHOD ViewDefVCF(oView) CLASS CRM980EventDEFDMS
	Local aMCampos := {}	
	Local oStruct 

	if ::lVCF
		aMCampos := {"VCF_SCRMED", "VCF_SCRMSC"}	
		oStruct := GetStructZz(aMCampos, 2)						  
		oView:CreateHorizontalBox("FOLDER_DMS", 10, , , "FOLDER", "SHEETAI0")
		oView:AddField("VCFFIELDS", oStruct, "SA1MASTER")
		oView:SetOwnerView("VCFFIELDS", "FOLDER_DMS")
		oView:EnableTitleView("VCFFIELDS", STR0014) //#STR0014 #"Complemento DMS"		
	endif
Return


METHOD AfterTTS(oModel, cModelId) CLASS CRM980EventDEFDMS

	local nAuxOper := oModel:GetOperation()
	local aCposCab := {}
	local lCriaContato := .f.
	local lBlackbird := .t.
	local cA1CODIGO := ''
	local cA1LOJA := ''
	local cVCFSCRMED := ''
	local cVCFSCRMSC := ''
	local lFound := .f.
	local aCab := {}
	local nOpc := nAuxOper

	If nAuxOper == MODEL_OPERATION_INSERT .or. nAuxOper == MODEL_OPERATION_UPDATE .or. nAuxOper == MODEL_OPERATION_DELETE
	Else
		Return .t.
	EndIf

	if ::lMVMIL0185 == .f. // Verifica se o ambiente esta integrado com o Blackbird
		lBlackbird := .f.
	endif 

	if lBlackbird
	Conout(" ")
	Do Case
		Case nAuxOper == MODEL_OPERATION_INSERT .or. nAuxOper == MODEL_OPERATION_UPDATE

			If ! existsVK7()

				// Conout(" ")
				// Conout("  _  _   _     ___ _    _      __ ___ _        _  _  ")
				// Conout(" /  |_) |_  /\  | |_   /  | | (_   | / \ |\/| |_ |_) ")
				// Conout(" \_ | \ |_ /--\ | |_   \_ |_| __)  | \_/ |  | |_ | \ ")
				// Conout("                                                     ")
				// Conout(" ")

				if CreateCustomer(aCposCab, nAuxOper)
					if SA1->A1_PESSOA == "F" .and. ! empty(SA1->A1_CGC)

						cMVMIL0187 := ::cMVMIL0187
						do case
						case cMVMIL0187 == "0"
							lCriaContato := .f.
						case cMVMIL0187 == "1"
							lCriaContato := .t.
						case cMVMIL0187 == "2"
							if FWGetRunSchedule() .or. MsgYesNo(STR0001) // "Deseja criar um registro de contato com base nos dados do cliente?"
								lCriaContato := .t.
							endif
						endcase

						if lCriaContato
							lContinua := CreateContact()

							if lContinua
								RelacContato()
							endif
						endif
						
					endif
				endif

			Else

				// Conout(" ")
				// Conout("      _   _      ___ _    _      __ ___ _        _  _  ")
				// Conout(" | | |_) | \  /\  | |_   /  | | (_   | / \ |\/| |_ |_) ")
				// Conout(" |_| |   |_/ /--\ | |_   \_ |_| __)  | \_/ |  | |_ | \ ")
				// Conout("                                                       ")
				// Conout(" ")

				CreateCustomer(aCposCab, nAuxOper)

			EndIf

			// Verifica se existe algum contato nao relacionado
			SincRelacionamentos(SA1->A1_COD, SA1->A1_LOJA)
			//


		Case nAuxOper == MODEL_OPERATION_DELETE

			// Conout(" ")
			// Conout("  _   _       _        _    _      __ ___ _        _  _   ")
			// Conout(" |_) |_ |\/| / \ \  / |_   /  | | (_   | / \ |\/| |_ |_)  ")
			// Conout(" | \ |_ |  | \_/  \/  |_   \_ |_| __)  | \_/ |  | |_ | \  ")
			// Conout("                                                          ")
			// Conout(" ")

			// RemoveCustomer()
			// RemoveGroup()

	EndCase
	Conout(" ")
	endif

	//Integrando com VEICM560 (adicionais do cliente DMS)
	If ::lVeiculo .and. (::lInsert .or. ::lUpdate)
		cA1CODIGO := oModel:GetValue("SA1MASTER", "A1_COD")
		cA1LOJA := oModel:GetValue("SA1MASTER", "A1_LOJA")
		cVCFSCRMED := oModel:GetValue("SA1MASTER", "VCF_SCRMED")
		cVCFSCRMSC := oModel:GetValue("SA1MASTER", "VCF_SCRMSC")
	
		DbSelectArea("VCF")
		if ::lUpdate
			VCF->(DbGotop())
			VCF->(DbSetOrder(1))
			lFound := VCF->(DbSeek(xFilial("VCF") + cA1CODIGO + cA1LOJA))

			if !lFound
				nOpc := MODEL_OPERATION_INSERT
			endif
		endif

		if ::lInsert
			VCF->(DbGotop())
			VCF->(DbSetOrder(1))
			lFound := VCF->(DbSeek(xFilial("VCF") + cA1CODIGO + cA1LOJA))

			if lFound
				nOpc := MODEL_OPERATION_UPDATE
			endif
		endif

		aadd(aCab,{"VCF_FILIAL",xFilial('VCF'),Nil})
		aadd(aCab,{"VCF_CODCLI",cA1CODIGO,Nil})
		aadd(aCab,{"VCF_LOJCLI",cA1LOJA,Nil})

		if empty(cVCFSCRMED)
			cVCFSCRMED := ' '
		endif

		if empty(cVCFSCRMSC)
			cVCFSCRMSC := ' '
		endif

		aadd(aCab,{"VCF_SCRMED",cVCFSCRMED,Nil})
		aadd(aCab,{"VCF_SCRMSC",cVCFSCRMSC,Nil})

		MSExecAuto({|x,y| VEICM560(,,x,y)},aCab,nOpc)
		
	EndIf

RETURN .T.


// Tudo OK da Tela //
METHOD ModelPosVld(oModel, cId) CLASS CRM980EventDEFDMS

local nAuxOper  := oModel:GetOperation()
local cAuxCpo   := " "

if GetNewPar("MV_MIL0185",.f.) == .f. // Verifica se o ambiente esta integrado com o Blackbird
	return .t.
endif 

If nAuxOper == MODEL_OPERATION_INSERT .or. nAuxOper == MODEL_OPERATION_UPDATE
	cAuxCpo := oModel:GetValue("SA1MASTER", "A1_PESSOA")
	If Empty(cAuxCpo)
		Help("",1,"ModelPosVld",,STR0013,1,0) // Necessário realizar o preenchimento do campo Fisica/Jurid (A1_PESSOA).
		return.f.
	Endif
Endif

RETURN .t.



/*/{Protheus.doc} SincRelacionamentos
Sincroniza contatos relacionados ao cliente

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function SincRelacionamentos(cA1Cod, cA1LOJA)

	local cSQL
	local oModel 
	local cEntity  := "SA1"
	local cFilEnt  := SA1->A1_FILIAL
	local cCodEnt  := SA1->A1_COD + SA1->A1_LOJA
	local cKey     := cFilEnt + cCodEnt

	local oSqlHelp := Dms_SqlHelper():New()
	local cConCod  := oSqlHelp:Concat({"'"+cA1Cod+"'", "'"+cA1LOJA+"'"}) 
	local cConFil  := oSqlHelp:Concat({'A1.A1_COD', 'A1.A1_LOJA'}) 

	//cSQL := "SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_PESSOA, AC8_ENTIDA , AC8_FILENT , AC8_CODENT , AC8.AC8_CODCON 
	cSQL := "SELECT COUNT(*)" + ;
		" FROM " + RetSQLName("AC8") + " AC8" + ;
		" JOIN " + RetSQLName("SA1") + " A1 ON A1.A1_FILIAL = AC8.AC8_FILENT AND " + cConFil + " = AC8.AC8_CODENT AND A1.D_E_L_E_T_ = ' '" + ;
		" WHERE AC8_FILIAL = '" + xFilial("AC8") + "' AND AC8.D_E_L_E_T_ = ' '" + ;
		" AND AC8_ENTIDA = 'SA1' " + ;
		" AND AC8_CODENT = " + cConCod + ;
		" AND NOT EXISTS ( SELECT * FROM " + RetSQLName("VK8") + " VK8 WHERE VK8_FILIAL = ' ' AND VK8_A1FIL = AC8_FILENT AND VK8_A1COD = A1_COD AND VK8_A1LOJA = A1_LOJA AND VK8.D_E_L_E_T_ = ' ' AND VK8.VK8_U5FIL = AC8.AC8_FILIAL AND VK8.VK8_U5COD = AC8.AC8_CODCON)"

	IF FM_SQL(cSQL) == 0
		Return
	endif

	AC8->(DBSetOrder(2)) // AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
	SU5->(DbSetOrder(1))
	
	//If ! AC8->( MSSeek( xFilial("AC8") + cEntity + cKey ) )
	//	Return
	//endif

	DbselectArea("AC8")
	dbSetOrder(1)

	if oCRMA060 == NIL
		oCRMA060 := FwLoadModel("CRMA060")
	endif
	oCRMA060:SetOperation( MODEL_OPERATION_UPDATE )
	oCRMA060:GetModel("AC8MASTER"):bLoad := { || { xFilial("AC8") , xFilial( "SA1" ) , cEntity , cCodEnt , "" }}
 	oCRMA060:Activate()
	If oCRMA060:IsActive()
		oCRMA060:lModify := .t.
		If oCRMA060:VldData()
			oCRMA060:CommitData()
		endif
	endif
	oCRMA060:DeActivate()


Return


/*/{Protheus.doc} RemoveCustomer
Remove customer relacionado ao cliente

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
/*
Static Function RemoveCustomer()

	if ! existsVK7()
		return .t.
	endif

	oModel := FWLoadModel("OFIA402")
	oModel:setOperation(MODEL_OPERATION_UPDATE)

	if ! oModel:Activate()
		Return .f.
	endif

	oModel:SetValue("MODEL_VK7", "VK7_A1DEL", "1" )
	If oModel:VldData()
		oModel:CommitData()
	endif
	oModel:DeActivate()

	OA4020053_ExcluirBlackBird("VK7",VK7->(Recno()),4,.f.)
	dbSelectarea("SA1")

Return
*/

/*/{Protheus.doc} CreateCustomer
Grava dados da VK7

@type method
@author Rubens
@since 20/07/2022
/*/
Static Function CreateCustomer(aCpoVK7, nAuxOper )
	Local oModel, oAux, oStruct
	Local nI        := 0

	Local nPos      := 0
	Local lRet      := .T.
	Local aAux	     := {}
	Local lAux      := .T.
	Local cModelVK7 := 'MODEL_VK7'

	Local aSplitName
	Local c2end     := getNewPar("MV_MIL0199","1")	// Segundo End. Cliente: 0=Principal;1=Cobrança;2=Entrega
	Local nCodCKC :=0

	aCpoVK7 := {}
	aAdd( aCpoVK7, { 'VK7_GROUP ' , '0' , NIL } )
	aAdd( aCpoVK7, { 'VK7_CNUMB ' , SA1->A1_COD + SA1->A1_LOJA , NIL } )
	//aAdd( aCpoVK7, { 'VK7_BTNUMB' , SA1->A1_COD, NIL } )

	if SA1->A1_PESSOA == "F"
		aAdd( aCpoVK7, { 'VK7_TYPE' , "1"    , NIL } ) // 1=Individual

		aSplitName := SplitName(SA1->A1_NOME)

		aAdd( aCpoVK7, { 'VK7_FSNAME' , aSplitName[1] , NIL } )
		aAdd( aCpoVK7, { 'VK7_LSNAME' , aSplitName[2] , NIL } )
	endif

	if SA1->A1_PESSOA == "J"
		aAdd( aCpoVK7, { 'VK7_TYPE' , "2"    , NIL } ) // 2=Business
		aAdd( aCpoVK7, { 'VK7_CPNAME' , SA1->A1_NOME    , NIL } )
	endif

	cSQL := "SELECT VJP.VJP_ID" + ;
		" FROM " + RetSQLName("VJP") + " VJP" + ;
		" JOIN " + RetSQLName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' " +;
		" AND VJP.VJP_A1COD = SA1.A1_COD AND VJP.VJP_A1LOJA = SA1.A1_LOJA AND VJP.D_E_L_E_T_ = ' ' " +;
		" WHERE VJP.VJP_FILIAL = '" + xFilial("VJP") + "' "+;
		" AND VJP.VJP_A1COD = '"+SA1->A1_COD+"' " +;
		" AND VJP.VJP_A1LOJA = '"+SA1->A1_LOJA+"' " +;
		" AND SA1.D_E_L_E_T_ = ' ' "

	nCodCKC := FM_SQL(cSQL)

	aAdd( aCpoVK7, { 'VK7_EMAIL' , OFXFA0184_AtePontoVirgula(alltrim(SA1->A1_EMAIL)) , NIL } )
	//aAdd( aCpoVK7, { 'VK7_EMAIL3', StrTran(alltrim(SA1->A1_EMAIL), OFXFA0184_AtePontoVirgula(alltrim(SA1->A1_EMAIL)) + ';', "") , NIL } )
	aAdd( aCpoVK7, { 'VK7_STATUS' , alltrim(SA1->A1_MSBLQL) , NIL } )   //Adicionado para considerar quando altera o campo A1_MSBLQL - Mauro - Innovare 07/08/2023
	aAdd( aCpoVK7, { 'VK7_PAEND1' , alltrim(SA1->A1_END) , NIL } )
	aAdd( aCpoVK7, { 'VK7_PAEND2' , alltrim(SA1->A1_BAIRRO) , NIL } )
	aAdd( aCpoVK7, { 'VK7_PAEND3' , alltrim(SA1->A1_COMPLEM) , NIL } )
	aAdd( aCpoVK7, { 'VK7_PACIDA' , alltrim(SA1->A1_MUN) , NIL } )
	aAdd( aCpoVK7, { 'VK7_PAESTA' , alltrim(SA1->A1_EST) , NIL } )
	if !Empty(nCodCKC)
		aAdd( aCpoVK7, { 'VK7_CKCID'  , nCodCKC , NIL } )	
	Endif
	if ! empty(A1_END)
		aAdd( aCpoVK7, { 'VK7_PAPAIS' , "BRA" , NIL } )
	endif
	aAdd( aCpoVK7, { 'VK7_PACEP ' , alltrim(SA1->A1_CEP) , NIL } )

	if c2end == "0"			// Segundo End. cliente: Principal
		aAdd( aCpoVK7, { 'VK7_MAEND1' , alltrim(SA1->A1_END)    , NIL } )
		aAdd( aCpoVK7, { 'VK7_MAEND2' , alltrim(SA1->A1_BAIRRO) , NIL } )
		aAdd( aCpoVK7, { 'VK7_MAEND3' , alltrim(SA1->A1_COMPLEM), NIL } )
		aAdd( aCpoVK7, { 'VK7_MACIDA' , alltrim(SA1->A1_MUN)    , NIL } )
		aAdd( aCpoVK7, { 'VK7_MAESTA' , alltrim(SA1->A1_EST)    , NIL } )
		if ! empty(A1_END)
			aAdd( aCpoVK7, { 'VK7_MAPAIS' , "BRA" , NIL } )
		endif
		aAdd( aCpoVK7, { 'VK7_MACEP ' , alltrim(SA1->A1_CEP)    , NIL } )

	elseif c2end == "1"		// Segundo End. cliente: Cobrança
		if empty( SA1->A1_ENDCOB )		// se vazio, envia principal
			aAdd( aCpoVK7, { 'VK7_MAEND1' , alltrim(SA1->A1_END) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND2' , alltrim(SA1->A1_BAIRRO) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND3' , alltrim(SA1->A1_COMPLEM) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MACIDA' , alltrim(SA1->A1_MUN) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAESTA' , alltrim(SA1->A1_EST) , NIL } )
			if ! empty(A1_END)
				aAdd( aCpoVK7, { 'VK7_MAPAIS' , "BRA" , NIL } )
			endif
			aAdd( aCpoVK7, { 'VK7_MACEP ' , alltrim(SA1->A1_CEP) , NIL } )
		else
			aAdd( aCpoVK7, { 'VK7_MAEND1' , allTrim(SA1->A1_ENDCOB) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND2' , allTrim(SA1->A1_BAIRROC), NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND3' , "", NIL } )
			aAdd( aCpoVK7, { 'VK7_MACIDA' , allTrim(SA1->A1_MUNC)   , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAESTA' , allTrim(SA1->A1_ESTC)   , NIL } )
			if ! empty(A1_ENDCOB)
				aAdd( aCpoVK7, { 'VK7_MAPAIS' , "BRA", NIL } )
			endif
			aAdd( aCpoVK7, { 'VK7_MACEP ' , allTrim(SA1-> A1_CEPC)  , NIL } )
		endif

	elseif c2end == "2"		// Segundo End. cliente: Entrega
		if empty( SA1->A1_ENDENT )		// se vazio, envia principal
			aAdd( aCpoVK7, { 'VK7_MAEND1' , alltrim(SA1->A1_END) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND2' , alltrim(SA1->A1_BAIRRO) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND3' , alltrim(SA1->A1_COMPLEM) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MACIDA' , alltrim(SA1->A1_MUN) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAESTA' , alltrim(SA1->A1_EST) , NIL } )
			if ! empty(A1_END)
				aAdd( aCpoVK7, { 'VK7_MAPAIS' , "BRA" , NIL } )
			endif
			aAdd( aCpoVK7, { 'VK7_MACEP ' , alltrim(SA1->A1_CEP) , NIL } )
		else
			aAdd( aCpoVK7, { 'VK7_MAEND1' , allTrim(SA1->A1_ENDENT) , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND2' , allTrim(SA1->A1_BAIRROE), NIL } )
			aAdd( aCpoVK7, { 'VK7_MAEND3' , allTrim(SA1->A1_COMPENT), NIL } )
			aAdd( aCpoVK7, { 'VK7_MACIDA' , allTrim(SA1->A1_MUNE)   , NIL } )
			aAdd( aCpoVK7, { 'VK7_MAESTA' , allTrim(SA1->A1_ESTE)   , NIL } )
			if ! empty(A1_ENDENT)
				aAdd( aCpoVK7, { 'VK7_MAPAIS' , "BRA", NIL } )
			endif
			aAdd( aCpoVK7, { 'VK7_MACEP ' , allTrim(SA1-> A1_CEPE)  , NIL } )
		endif
	endif

	aAdd( aCpoVK7, { 'VK7_DOBUAS' , allTrim(SA1->A1_NREDUZ) , NIL } )
	if ! empty(SA1->A1_TEL)
		aAdd( aCpoVK7, { 'VK7_PPHONE' , allTrim(SA1->A1_DDD + " ") + allTrim(SA1->A1_TEL) , NIL } )
	endif

	if ! empty(SA1->A1_FAX)
		aAdd( aCpoVK7, { 'VK7_FAXNUM' , allTrim(SA1->A1_DDD + " ") + allTrim(SA1->A1_FAX) , NIL } )
	endif

	aAdd( aCpoVK7, { 'VK7_A1FIL'  , SA1->A1_FILIAL  , NIL } )
	aAdd( aCpoVK7, { 'VK7_A1COD'  , SA1->A1_COD     , NIL } )
	aAdd( aCpoVK7, { 'VK7_A1LOJA' , SA1->A1_LOJA    , NIL } )
	aAdd( aCpoVK7, { 'VK7_A1SYNC' , "1" , NIL } ) // Marca registro como 1=Sim
	aAdd( aCpoVK7, { 'VK7_A1DEL ' , "0" , NIL } ) // Marca registro como NAO EXCLUIDO
	aAdd( aCpoVK7, { 'VK7_CGC'    , SA1->A1_CGC     , NIL } )
	aAdd( aCpoVK7, { 'VK7_INSCR'  , SA1->A1_INSCR   , NIL } )

	If existsVK7()

		nAuxOper := MODEL_OPERATION_UPDATE

		if isEqual(aCpoVK7)
			conout(STR0011 + SA1->A1_FILIAL + " " + SA1->A1_COD + " " + SA1->A1_LOJA )	// "Customer nao precisa de alteracao: "
			return .t.
		endif

	Else
		nAuxOper := MODEL_OPERATION_INSERT
	EndIf

	aAdd( aCpoVK7, { 'VK7_BBSYNC' , "0" , NIL } ) // Marca registro como 0=Não

	if oOFIA402 == NIL
		oOFIA402 := FWLoadModel( 'OFIA402' )
	endif
	oOFIA402:SetOperation( nAuxOper )
	lRet := oOFIA402:Activate()

	If lRet

		// Verifica se o registro foi bloqueado
		if SA1->(FieldPos("A1_MSBLQL")) <> 0

			// 1 -> "Inativo"
			// 2 -> "Ativo"

			// Inativa o Customer
			if SA1->A1_MSBLQL == "1" .and. oOFIA402:GetValue( cModelVK7 , "VK7_STATUS") == "2"
				aAdd( aCpoVK7, { 'VK7_STATUS' , "1"    , NIL } )
				aAdd( aCpoVK7, { 'VK7_STAMOT' , STR0012, NIL } )	// "CLIENTE INATIVO NO TOTVS PROTHEUS"
				aAdd( aCpoVK7, { 'VK7_STADAT' , dDataBase , NIL } )
			endif

			// Ativa o customer
			if SA1->A1_MSBLQL == "2" .and. oOFIA402:GetValue( cModelVK7 , "VK7_STATUS") == "1"
				aAdd( aCpoVK7, { 'VK7_STATUS' , "2"    , NIL } )
				aAdd( aCpoVK7, { 'VK7_STAMOT' , " "    , NIL } )
				aAdd( aCpoVK7, { 'VK7_STADAT' , CtoD(" ") , NIL } )
			endif

		endif
		//

		oAux := oOFIA402:GetModel( cModelVK7 )
		oStruct := oAux:GetStruct()
		aAux	:= oStruct:GetFields()
		For nI := 1 To Len( aCpoVK7 )
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoVK7[nI][1] ) } ) ) > 0
				If !( lAux := oOFIA402:SetValue( cModelVK7, aCpoVK7[nI][1], aCpoVK7[nI][2] ) )
					lRet    := .F.
					Exit
				EndIf
			EndIf
		Next
	EndIf

	If lRet
		If ( lRet := oOFIA402:VldData() )
			lRet := oOFIA402:CommitData()
		EndIf
	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oOFIA402:GetErrorMessage()
		logAutoGR(aErro)

		if isBlind()
			Help(" ",1,"ERROR",,AllToChar(aErro[6]),4,1 )
		else
			MostraErro()
		endif
	EndIf

	// Desativamos o Model
	oOFIA402:DeActivate()
Return lRet


/*/{Protheus.doc} existsVK7
Verifica a existencia de customer do cliente

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function existsVK7()
	local lRet
	
	VK7->(dbSetOrder(2))
	lRet := VK7->(dbSeek(xFilial("VK7") + SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA ))

Return lRet

/*/{Protheus.doc} SplitName
Quebra o nome para gravacao correta do Customer

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function SplitName(cFullName)

	local cFirstName := ""
	local cLastName := cFullName
	local nPos

	cFullName := allTrim(cFullName)
	cLastName := cFullName

	// Retira o Sobrenome
	nPos := AT(" ",cFullName)
	If nPos <> 0
		cLastName := Right(cFullName,Len(cFullName) - nPos)
		cFirstName := AllTrim(Left(cFullName,nPos))
	EndIf

Return {cFirstName, cLastName}


/*/{Protheus.doc} CreateContact
Cria um contato com os dados do cliente

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function CreateContact()

	local aContact := {}
	local aEnds := {}
	local aPhones := {}

	//If ! FWGetRunSchedule() .and. MsgNoYes("CreateContact - Simular errorlog")
	//	UserException("CreateContact - Derrubando sistema")
	//endif

	if SA1->A1_PESSOA <> 'F'
		return .f.
	endif

	// Antes de criar um contato com o mesmo CPF, verifica se existe um contato relacionado ao cliente
	AC8->(dbSetOrder(2)) // AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
	if AC8->(dbSeek(xFilial("AC8") + "SA1" + xFilial("SA1") + SA1->A1_COD + SA1->A1_LOJA))
		return .f. // Deve retonar .f. para que o sistema nao tente criar o relacionamento novamente
	endif

	SU5->(dbSetOrder(8))
	if SU5->(dbSeek(xFilial("SU5") + alltrim(SA1->A1_CGC)))
		return .t.
	endif

	SU5->( DbSetOrder(1) )

	aAdd(aContact,{"U5_CONTAT"	, left(SA1->A1_NOME, TamSX3("U5_CONTAT")[1]) ,Nil})
	aAdd(aContact,{"U5_CPF" 	, alltrim(SA1->A1_CGC) ,Nil })

	// Adicionando Telefones
	addPhones(@aPhones, "1", SA1->A1_DDD, SA1->A1_TEL)
	addPhones(@aPhones, "3", SA1->A1_DDD, SA1->A1_FAX)
	//

	// Adicionando enderecos
	addEndereco(@aEnds)

	INCLUI := .t.
	ALTERA := .f.

	lMsErroAuto := .f.
	lMSHelpAuto := .f.
	MSExecAuto({|x,y,z,b|TMKA070(x,y,z,b)},aContact,3,aEnds,aPhones)
	If lMsErroAuto
		//Conout("ERRO ao tentar incluir contato")
		MostraErro()
		return .f.
	//Else
	//	Conout("CONTATO INCLUIDO COM SUCESSO ")
	endif

Return .t.

/*/{Protheus.doc} addPhones
Adiciona dados de telefone na array de integração

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function addPhones(aPhones, cTipo, cDDD, cPhone)

	local aPhone := {}

	if empty(cPhone)
		return
	endif

	aAdd(aPhone,{"AGB_TIPO"   , cTipo , nil } ) // 1=Comercial;2=Residencial;3=Fax comercial;4=Fax residencial;5=Celular
	aAdd(aPhone,{"AGB_DDD"    , cDDD , nil } )
	aAdd(aPhone,{"AGB_TELEFO" , cPhone , nil } )
	aAdd(aPhone,{"AGB_PADRAO" , iif( len(aPhones) == 0 , "1", "2") , nil } )
	AAdd(aPhones, aPhone)

Return


/*/{Protheus.doc} addEndereco
Adiciona dados de endereco na array de integração

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function addEndereco(aEnds)

	local aEnd := {}

	aAdd( aEnd , { "AGA_TIPO"   , "1" , NIL }) // 1=Comercial;2=Residencial
	aAdd( aEnd , { "AGA_PADRAO" , "1" , NIL }) // 1=Sim;2=Não
	aAdd( aEnd , { "AGA_END"    , alltrim(SA1->A1_END)     , NIL })
	aAdd( aEnd , { "AGA_BAIRRO" , alltrim(SA1->A1_BAIRRO)  , NIL })
	aAdd( aEnd , { "AGA_CEP"    , alltrim(SA1->A1_CEP)     , NIL })
	aAdd( aEnd , { "AGA_EST"    , alltrim(SA1->A1_EST)     , NIL })
	aAdd( aEnd , { "AGA_MUN"    , alltrim(SA1->A1_COD_MUN) , NIL })
	aAdd( aEnd , { "AGA_PAIS"   , alltrim(SA1->A1_PAIS)    , NIL })
	if ! empty(SA1->A1_COMPLEM)
		aAdd( aEnd , { "AGA_COMP"   , alltrim(SA1->A1_COMPLEM) , NIL })
	endif
	AAdd(aEnds, aEnd)
Return


/*/{Protheus.doc} RelacContato
Relaciona um contato a um cliente

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
Static Function RelacContato()

	local cEntity := "SA1"
	local cFilEnt := SA1->A1_FILIAL
	local cCodEnt := SA1->A1_COD + SA1->A1_LOJA
	local cKey := cFilEnt + cCodEnt
	local cCodCon := SU5->U5_CODCONT
	local oModel

	local cCodDesc := AllTrim(cCodEnt) + "-" + SA1->A1_NOME
	local cNomEnt  := AllTrim(FWX2Nome(cEntity)) + " - " + cCodDesc

	local lRet := .t.

	DBSelectArea("AC8")
	//AC8_FILIAL+AC8_ENTIDA+AC8_FILENT+AC8_CODENT+AC8_CODCON
	AC8->(DBSetOrder(2))
	SU5->(DbSetOrder(1))

	if oCRMA060 == NIL
		oCRMA060 := FwLoadModel("CRMA060")
	endif
	if AC8->( MSSeek( xFilial("AC8") + cEntity + cKey ) )
		oCRMA060:SetOperation( MODEL_OPERATION_UPDATE )
	else
		oCRMA060:SetOperation( MODEL_OPERATION_INSERT )
	endif
	oCRMA060:GetModel("AC8MASTER"):bLoad := {|| {xFilial("AC8"),xFilial( cEntity )  ,cEntity  ,cKey,cNomEnt}}
	oCRMA060:Activate()

	If oCRMA060:IsActive()

		if oCRMA060:GetOperation() == MODEL_OPERATION_INSERT
			oCRMA060:SetValue("AC8MASTER","AC8_FILIAL",xFilial("AC8"))
			oCRMA060:SetValue("AC8MASTER","AC8_ENTIDA","SA1")
			oCRMA060:SetValue("AC8MASTER","AC8_FILENT",cFilEnt)
			oCRMA060:SetValue("AC8MASTER","AC8_CODENT",cCodEnt)
		endif

		oMdlGrid := oCRMA060:GetModel("AC8CONTDET")
		nLength := oMdlGrid:Length()

		If nLength == 1 .and. empty(oMdlGrid:GetValue("AC8_CODCON"))
			oMdlGrid:SetValue("AC8_CODCON",cCodCon)

			if oCRMA060:GetOperation() == MODEL_OPERATION_INSERT
				oMdlGrid:SetValue("AC8_PRIMAR","1")
			endif

		elseIf oMdlGrid:AddLine() > nLength
			oMdlGrid:SetValue("AC8_CODCON",cCodCon)
		EndIf

		If oCRMA060:VldData()
			oCRMA060:CommitData()
		Else
			lRet := .F.
			aErro := oCRMA060:GetErrorMessage()

			if isBlind()
				logConout(aErro)
			else
				logAutoGR(aErro)
			endif
		EndIf

		oCRMA060:DeActivate()
	Else
		lRet	:= .F.
		aErro	:= oCRMA060:GetErrorMessage()
		if isBlind()
			logConout(aErro)
		else
			logAutoGR(aErro)
		endif
	EndIf
Return lRet

static function logAutoGR(aErro)
	AutoGrLog( STR0002 + ' [' + AllToChar(aErro[1]) + ']' ) // "Id do formulário de origem:"
	AutoGrLog( STR0003 + ' [' + AllToChar(aErro[2]) + ']' ) // "Id do campo de origem:     "
	AutoGrLog( STR0004 + ' [' + AllToChar(aErro[3]) + ']' ) // "Id do formulário de erro:  "
	AutoGrLog( STR0005 + ' [' + AllToChar(aErro[4]) + ']' ) // "Id do campo de erro:       "
	AutoGrLog( STR0006 + ' [' + AllToChar(aErro[5]) + ']' ) // "Id do erro:                "
	AutoGrLog( STR0007 + ' [' + AllToChar(aErro[6]) + ']' ) // "Mensagem do erro:          "
	AutoGrLog( STR0008 + ' [' + AllToChar(aErro[7]) + ']' ) // "Mensagem da solução:       "
	AutoGrLog( STR0009 + ' [' + AllToChar(aErro[8]) + ']' ) // "Valor atribuido:           "
	AutoGrLog( STR0010 + ' [' + AllToChar(aErro[9]) + ']' ) // "Valor anterior:            "
return

static function logConout(aErro)
	conout( STR0002 + ' [' + AllToChar(aErro[1]) + ']') // "Id do formulário de origem:"
	conout( STR0003 + ' [' + AllToChar(aErro[2]) + ']') // "Id do campo de origem: "    
	conout( STR0004 + ' [' + AllToChar(aErro[3]) + ']') // "Id do formulário de erro: " 
	conout( STR0005 + ' [' + AllToChar(aErro[4]) + ']') // "Id do campo de erro: "      
	conout( STR0006 + ' [' + AllToChar(aErro[5]) + ']') // "Id do erro: "               
	conout( STR0007 + ' [' + AllToChar(aErro[6]) + ']') // "Mensagem do erro: "         
	conout( STR0008 + ' [' + AllToChar(aErro[7]) + ']') // "Mensagem da soluçao: "      
	conout( STR0009 + ' [' + AllToChar(aErro[8]) + ']') // "Valor atribuído: "          
	conout( STR0010 + ' [' + AllToChar(aErro[9]) + ']') // "Valor anterior: "           
return

/*/{Protheus.doc} isEqual
Verifica se existe algum diferenca dos campos para executar ExecAuto

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
static Function isEqual(aFields)

	local nLinFields
	local cAliasTab := "VK7"

	for nLinFields := 1 to len(aFields)

		if RetEsp(aFields[nLinFields,2]) == RetEsp(&(cAliasTab + '->' + aFields[nLinFields,1] ))
		else
			return .f.
		endif

	next 

return .t.


/*/{Protheus.doc} RemoveGroup
Remove agrupamento de cliente.

@type function
@author Rubens Takahashi
@since 04/01/2022
/*/
/*
Static Function RemoveGroup()

	Local nQtdCli := 0
	Local cChaveSA1 := SA1->A1_FILIAL + SA1->A1_COD + SA1->A1_LOJA

	VK7->(dbSetOrder(2))
	If ! VK7->(dbSeek(xFilial("VK7") + cChaveSA1 ))
		Return .t.
	EndIf

	If !Empty(VK7->VK7_CODVK7)
		VK7->(dbSetOrder(1))
		VK7->(dbSeek(xFilial("VK7") + VK7->VK7_CODVK7 )) // Posiciona com o código do Grupo

		nQtdCli := OA4020035_ClienteAgrupado(,,.t.,VK7->VK7_CNUMB)

		If nQtdCli <= 1
			OA4020015_DesfazerGrupo()
		EndIf
	EndIf

Return
*/

//{Protheus.doc} SubstMCampo(): Converte chamadas de memoria M-> em chamadas com FwFldGet()
static Function SubstMCampo(cTexto)
	Local cOut := ""
	Local n := 1
	Local cChar

	While n <= Len(cTexto)
		cChar := Subs(cTexto, n, 1)

		If cChar == "M" .And. Subs(cTexto, n, 3) == "M->"
			cOut += 'FwFldGet("'
			n += 3 // pula "M->"

			While n <= Len(cTexto)
				cChar := Subs(cTexto, n, 1)
				If cChar $ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
					cOut += cChar
					n++
				Else
					Exit
				EndIf
			EndDo
			cOut += '")'
		Else
			cOut += cChar
			n++
		EndIf
	EndDo
Return cOut


/*/{Protheus.doc} GetStructZz(): Montagem dinamica de estrura da view /*/
static function GetStructZz(aCampos, nType)
    Local oStruct as Object
    Local nI, cCampo, cTitulo, cDesc, cType, cPict, cCBox, aCombo, nTam

    oStruct := FWFormViewStruct():New()
    
    For nI := 1 To Len(aCampos)
        cCampo := aCampos[nI]
        cTitulo := AllTrim(GetSX3Cache(cCampo, "X3_TITULO"))
        cDesc   := AllTrim(GetSX3Cache(cCampo, "X3_DESCRIC"))
        cType   := GetSX3Cache(cCampo, "X3_TIPO")
        cPict   := GetSX3Cache(cCampo, "X3_PICTURE")
        cCBox   := GetSX3Cache(cCampo, "X3_CBOX")
        aCombo  := IIf(Empty(cCBox), {}, StrTokArr2(cCBox, ";"))
        nTam    := FWTamSX3(cCampo)[1]

        // View: cIdField, cOrdem, cTitulo, cDescric, ..., lVirtual
        oStruct:AddField(cCampo, StrZero(nI), cTitulo, cDesc, , cType, cPict, , , .T., , , aCombo, 0, , .T.)

    Next nI
Return oStruct

/*/{Protheus.doc} ExisteAliasVCF
	@type  Function - Avalia parametros e existencia de campos para montagem de tela auxiliar
	@author Emanuel F. Bezerra
	@since 04/02/2026
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
static Function adicionaCamposVCF()
	local lVCF := FWAliasInDic("VCF", .F.)
	Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // 
	Local aSegmentos := StrTokArr(AllTrim(cMVMIL0006), "/")	
	local lVEICM560 := ExistFunc('VEICM560')
	local lMVVEIC	:= SuperGetMV("MV_VEICULO",.F.,"N") == "S"		
	local lVCFSCRMED := .f.
	local lVCFSCRMSC := .f.
	local lRet := .f.	
	Local lVA560Atu := .f.
	local nI := 0

	For nI := 1 To Len(aSegmentos)
		If Upper(AllTrim(aSegmentos[nI])) == "SCA"
			lVA560Atu := .T.
			Exit
		EndIf
	Next nI

	if lVCF .and. lMVVEIC .and. lVEICM560 .and. lVA560Atu
		lVCFSCRMED := Len(FWTamSX3("VCF_SCRMED")) > 0 .And. VCF->(FieldPos("VCF_SCRMED") > 0)
		lVCFSCRMSC := Len(FWTamSX3("VCF_SCRMSC")) > 0 .And. VCF->(FieldPos("VCF_SCRMSC") > 0)	

		if lVCFSCRMED .and. lVCFSCRMSC
			lRet := .t.
		endif
	endif

Return lRet


/*/{Protheus.doc} RetEsp
Retira espaços com o alltrim dependendo do conteudo do campo

@type function
@author Francisco Carvalho
@since 09/06/2026
/*/
Static Function RetEsp(uValue)
    If ValType(uValue) == "C"
        Return AllTrim(uValue)
    Endif
Return uValue