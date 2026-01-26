#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA280EVDF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD FieldPreVld()

ENDCLASS



METHOD New() CLASS VEIA280EVDF

RETURN .T.


METHOD FieldPreVld(oModel, cModelID, cAction, cId, xValue) CLASS VEIA280EVDF

	Local cConteudo := ""
	Local cNomAtri  := ""
	Local cNomUsr   := ""

	If cAction == "SETVALUE"

		cConteudo := xValue

		if cId == "VAL_USPCON"

			cNomUsr  := UsrRetName(cConteudo)
			oModel:LoadValue( "VAL_NOMPUS", Alltrim(cNomUsr) )

		Elseif cId == "VAL_ATRIB"

			cNomAtri := OFIOA560DS("086",cConteudo)
			oModel:LoadValue( "VAL_NOMATR", Alltrim(cNomAtri) )

		EndIf
	EndIf

RETURN .t.


METHOD Activate(oModel, lCopy) CLASS VEIA280EVDF

	If IsInCallStack("VEIXA018")

		if oModel:GetOperation() == 3
			oModel:SetValue("VALMASTER" ,"VAL_TIPO" , "0" )
			oModel:SetValue("VALMASTER" ,"VAL_NUMATE" , VV9->VV9_NUMATE )
			oModel:LoadValue("VALMASTER","VAL_OBSUSU" , VV9->VV9_OBSUSU )
			oModel:LoadValue("VALMASTER","VAL_OBSERV" , MSMM(VV9->VV9_OBSMEM,70) )
			oModel:LoadValue("VALMASTER","VAL_OBSHIS" , MSMM(VV0->VV0_OBSMEM,70) )
		EndIf


	Endif

RETURN .T.