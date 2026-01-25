#INCLUDE "fina084.ch"
#include 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"

#Define  CANCEL_FUNCTION "FA084CanC()"

Function Fina084RUS()
Return Fina084()

/*/{Protheus.doc} BrowseDef
    (long_description)
    @type  Static Function
    @author user
    @since 02/12/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function BrowseDef()
Return FWmBrowse():New()

Static Function MenuDef()
    Local aMenu As Array
    Local nX    As Numeric
    aMenu := FwLoadMenuDef("fina084")
    nX := ASCAN(aMenu, {|x| x[4] == 5 }) //find cancel operation
    If nX > 0
        aMenu[nX][2] := CANCEL_FUNCTION // change cancel function
    EndIf
Return aMenu

/*/{Protheus.doc} Fa084RUS01_DeleteSFR(cFR_CHAVOR, cFR_CARTEI)
	@type  Function
	@author astepanov
	@since 05/09/2023
	@version 1.0
	@param cFR_CHAVOR, Character, SFR->FR_CHAVOR value for searching in SFR table
    @param cFR_CARTEI, Character, SFR->FR_CARTEI value for searching in SFR table
	@return lRet, Logical, .T. - all is ok, .F.  - some record was not locked
	@example
	(examples)
	@see (links_or_references)
/*/
Function Fa084RUS01_DeleteSFR(cFR_CHAVOR, cFR_CARTEI)
	Local lRet       := .T.
	Local aSFRRecs   As Array
	aSFRRecs := {}
	If 	RecLock("SFR",.F.)
		lRet := ValidBefDel(@aSFRRecs, cFR_CHAVOR, cFR_CARTEI) //run validations according to business rules before deletion
		If lRet
			SFR->(DbDelete())
			lRet := Chg_SFR(aSFRRecs) //change SFR records which were added to aSFRRecs by ValidBefDel
		Endif
		If !Empty(aSFRRecs)
			Unlock_SFR(aSFRRecs)
		EndIf
		SFR->(MsUnLock())
	Else
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} ValidBefDel(aSFRRecs)
  	General idea. There is an AP in foreign currency, we write it off with several write-offs, 
    not following the order of write-offs (we can first make the write-off a later date
    and then earlier. In this case the calculation of some exchange rate differences is not correct. 
    At the moment of an incorrect sequence of dates the write-off program analyzes all write-offs 
    carried out and in the SFR table, in the records from those that need to be adjusted (at later dates).
    FR_RDBBAL field should be marked as "1". This indicates that amount in FR_VALOR needs to be adjusted.
    If you then run the FINA084 program on the original invoice, it will create adjustment entries
    for those write-offs that need to be adjusted, and FR_RBDBAL field will change from "1" to "2" for them.
    Also at each write-off and at the final recalculation through FINA084, a debit or credit note is created
    in the system for the amount of the exchange rate adjustment.
    In case the last credit note is deleted in the system (which arose during the execution of FINA084 
    and made the final exchange rate adjustment for all write-offs, it is marked in FR_RBDBAL like "3"),
    we must change FR_RBDBAL from "2" to "1" in all records related to final exchange rate adjustment.

	We nust be positioned on correct SFR record
	@type  Static Function
	@author astepanov
	@since 12/09/2023
	@version version
	@param aSFRRecs, Array, We change this parameter if we want to change several SFR records adter delition original SFR record
	@param cFR_CHAVOR, Character, SFR->FR_CHAVOR value for searching in SFR table
    @param cFR_CARTEI, Character, SFR->FR_CARTEI value for searching in SFR table
	@return lRet, Logical, .T. - ok, .F. - abort all operation
	@example
	(examples)
	@see https://jiraproducao.totvs.com.br/browse/RULOC-5323
/*/
Static Function ValidBefDel(aSFRRecs, cFR_CHAVOR, cFR_CARTEI)
	Local lRet       As Logical
	Local aArea      As Array
	Local aAreaSFR   As Array
	Local cFil       As Character
    Local cKey       As Character
	Local dEmpty     As Date
    Local dFR_DATADI As Date

	lRet := .T.
	dFR_DATADI := SFR->FR_DATADI
	cFil := xFilial("SFR")
	cKey := cFil+cFR_CARTEI+cFR_CHAVOR
	If SFR->FR_RBDBAL == "3"
		// If we delete exchange rate correction
		// we must change FR_RBDBAL in all related documents from "2" to "1"
		aArea    := GetArea()
		aAreaSFR := SFR->(GetArea())
		SFR->(DBSetOrder(1)) //FR_FILIAL+FR_CARTEI+FR_CHAVOR+DTOS(FR_DATADI)
		dEmpty := Ctod('')
		If SFR->(DBSeek(cKey),.T.)
			While lRet .AND. cKey == SFR->FR_FILIAL+SFR->FR_CARTEI+SFR->FR_CHAVOR
				If SFR->FR_RBDBAL == "3" .AND. SFR->FR_DATADI > dFR_DATADI
					// we have future revaluations, so we can't delete this revaluation
					// at firts we should cancel future revaluations
					lRet := .F.
					HELP("",1,  STR0007,,; //Accounts payable exchange rate diff.
							STR0005,;            //Cancel
							1,0,,,,,,;
							{STR0055}) //We can't cancel this document because we have revalutions saved by future dates
				EndIf
				If SFR->FR_RBDBAL == "2" .AND. SFR->FR_DTFIX == dFR_DATADI
					If RecLock("SFR",.F.) // the record will be unlocked in Chg_SFR function in normal case or in Unlock_SFR
						If SFR->FR_RBDBAL == "2" .AND. SFR->FR_DTFIX == dFR_DATADI // check same case again after record locking
							AADD(aSFRRecs, {SFR->(Recno()),{"FR_RBDBAL","1"},{"FR_DTFIX",dEmpty}})
						Else
							SFR->(MSUnlock())
						EndIf
					Else
						lRet := .F.
					EndIf
				EndIf
				SFR->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaSFR)
		RestArea(aArea)
	ElseIf SFR->FR_RBDBAL == "2" // this record has related revaluation record
		lRet := .F.
		HELP("",1,  STR0007,,; //Accounts payable exchange rate diff.
				STR0005,;            //Cancel
				1,0,,,,,,;
				{STR0056}) //We can't cancel this document because we have revaluations which relates to this exchange rate difference
	ElseIf Empty(SFR->FR_RBDBAL) .OR. (SFR->FR_RBDBAL == "0")
		//this is normal exchange rate calculation, but we should  check future
		// or on same date corrections marked like "2" or "3"
		aArea    := GetArea()
		aAreaSFR := SFR->(GetArea())
		SFR->(DBSetOrder(1)) //FR_FILIAL+FR_CARTEI+FR_CHAVOR+DTOS(FR_DATADI)
		If SFR->(DBSeek(cKey),.T.)
			While lRet .AND. cKey == SFR->FR_FILIAL+SFR->FR_CARTEI+SFR->FR_CHAVOR
				If SFR->FR_RBDBAL == "2" .OR. SFR->FR_RBDBAL == "3"
					If SFR->FR_DATADI >= dFR_DATADI
						HELP("",1,  STR0007,,; //Accounts payable exchange rate diff.
								STR0005,;            //Cancel
								1,0,,,,,,;
								{STR0057}) //We can't cancel this document because we have corrections saved in future or in the same date
						lRet := .F.
					EndIf
				EndIf
				SFR->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaSFR)
		RestArea(aArea)
	EndIf
Return lRet

/*/{Protheus.doc} Chg_SFR
	Change SFR records
	@type  Static Function
	@author astepanov
	@since 12/09/2023
	@version version
	@param aSFRRecs, Array, Array in Format {{SFR->(Recno()),{"FIELD_NAME",NEW_FIELD_VALUE},...},...}
	@return lRet, Logical, if .T. all records were changed sucessfuly
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Chg_SFR(aSFRRecs)
	Local aArea    As Array
	Local aAreaSFR As Array
	Local lRet     As Logical
	Local nX       As Numeric
	Local nLen     As Numeric
	Local nY       As Numeric
	lRet := .T.
	aArea    := GetArea()
	aAreaSFR := SFR->(GetArea())
	If !Empty(aSFRRecs)
		nLen := Len(aSFRRecs)
		nX   := 1
		While lRet .AND. nX <= nLen
			SFR->(DBGoto(aSFRRecs[nX][1]))
			If RecLock("SFR",.F.)
				For nY := 2 To Len(aSFRRecs[nX])
					SFR->&(aSFRRecs[nX][nY][1]) := aSFRRecs[nX][nY][2]
				Next nY
				SFR->(MSUnlock())
			Else
				lRet := .F.
			EndIf
			nX   := nX + 1
		EndDo
	EndIf
	RestArea(aAreaSFR)
	RestArea(aArea)	
Return lRet

/*/{Protheus.doc} Unlock_SFR(aSFRRecs)
	Unlock SFR records provided by aSFRRecs array
	@type  Static Function
	@author astepanov
	@since 13/09/2023
	@version version
	@param param_name, param_type, param_descr
	@param aSFRRecs, Array, Array in Format {{SFR->(Recno()),{"FIELD_NAME",NEW_FIELD_VALUE},...},...}
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function Unlock_SFR(aSFRRecs)
	Local lRet     As Logical
	Local nX       As Numeric
	Local aArea    As Array
	Local aAreaSFR As Array
	lRet := .T.
	aArea := GetArea()
	aAreaSFR := SFR->(GetArea())
	For nX := 1 To Len(aSFRRecs)
		SFR->(DbGoto(aSFRRecs[nX][1]))
		SFR->(MSUnlock())
	Next nX
	RestArea(aAreaSFR)
	RestArea(aArea)
Return lRet
                   
//Merge Russia R14 
                   
