#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "VEIA073.CH"

CLASS VEIA073EVDEF FROM FWModelEvent

	data lEnviar

	METHOD New() CONSTRUCTOR
	METHOD AfterTTS()
	METHOD DeActivate()
	METHOD ModelPosVld()

ENDCLASS

METHOD NEW() CLASS VEIA073EVDEF
	self:lEnviar := .f.
RETURN

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA073EVDEF

	if oModel:GetValue("MODEL_VO0","VO0_ORIGEM") == "1" .and. oModel:GetOperation() == MODEL_OPERATION_INSERT

		if ! VA0730053_isLast(oModel:GetValue("MODEL_VO0","VO0_CHAINT"), oModel:GetValue("MODEL_VO0","VO0_DATA"), oModel:GetValue("MODEL_VO0","VO0_HORA"))
			FMX_HELP("VA073EVDEFERR001",STR0013,STR0014)	// "Existe um ou mais registro com data/hora maior que o registro informado."		"Informa data e hora maior que o último registro cadastrado na base de dados."
			return .f.
		endif

	endif

RETURN .t.

METHOD AfterTTS() CLASS VEIA073EVDEF
//local cAlias       := alias()
//local aAreaVV1     := VV1->( getArea() )
//local oModelVV1Aux := FWLoadModel( 'VEIA070' )

	self:lEnviar := .t.

//	oModelVV1Aux:SetOperation( MODEL_OPERATION_UPDATE )
//
//	VV1->( dbSetOrder(1) )
//	if VV1->( dbSeek( xFilial( "VV1" ) + VO0->VO0_CHAINT ) )
//		if oModelVV1Aux:Activate()
//			oModelVV1Aux:SetValue("MODEL_VV1", "VV1_ULTKIL" , VO0->VO0_KILOME )
//			oModelVV1Aux:SetValue("MODEL_VV1", "VV1_ULTTRI" , VO0->VO0_HORTRI )
//			if oModelVV1Aux:VldData()
//				oModelVV1Aux:CommitData()
//			endif
//		endif
//		oModelVV1Aux:DeActivate()
//	endif
//	freeObj(oModelVV1Aux)
//
//	VV1->( restArea( aAreaVV1 ) )
//	if ! empty( cAlias )
//		dbSelectArea( cAlias )
//	endif
RETURN

METHOD DeActivate(oModel) CLASS VEIA073EVDEF

	local nOperacao

	if self:lEnviar == .f.
		return
	endif

	if oModel:IsActive()
	else

		if VO0->VO0_BBINTG == "0"
			nOperacao := oModel:GetOperation()
			if nOperacao == MODEL_OPERATION_INSERT

//				Conout("Transmissao do Horimetro")

				VA0730013_TransmitirBlackBird("VO0",VO0->(Recno()),4,.f.)
				//
			endif
		EndIf
		
	endif
RETURN
