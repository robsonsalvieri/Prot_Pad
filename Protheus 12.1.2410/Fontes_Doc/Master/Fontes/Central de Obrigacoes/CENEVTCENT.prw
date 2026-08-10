#INCLUDE "TOTVS.CH"

Class CENEVTCENT FROM FWModelEvent
	Method AfterTTS(oModel, cModelId)
	Method New()
  Method Destroy()
End Class

Method New() Class CENEVTCENT
Return

Method Destroy()  Class CENEVTCENT       
Return

Method AfterTTS(oModel, cModelId,oBrwVcto,oBrowseDown) Class CENEVTCENT

	If SELECT("VCTOB3D") > 0
		dbselectarea('VCTOB3D')
		('VCTOB3D')->(DBGOTOP())
		While ('VCTOB3D')->(!Eof())
			Reclock('VCTOB3D',.F.)
			('VCTOB3D')->(DbDelete())
			MsUnlock()
			('VCTOB3D')->(DBSkip())
		EndDo

		If BuscaVctos()
			CarregaArqTmp()
		EndIf

	EndIf

	If SELECT("TEMPB3D") > 0
		dbselectarea('TEMPB3D')
		('TEMPB3D')->(DBGOTOP())
		While ('TEMPB3D')->(!Eof())
			Reclock('TEMPB3D',.F.)
			('TEMPB3D')->(DbDelete())
			MsUnlock()
			('TEMPB3D')->(DBSkip())
		End Do
		If BuscaB3D()
			LoadB3DTmp()
		EndIf
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros criticados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(oTmpTab)
	Local aB3A	:= B3A->(GetArea())

	While !TRBB3D->(Eof())

		RecLock('VCTOB3D',.T.)
		VCTOB3D->B3D_VCTO 	:= STOD(TRBB3D->B3D_VCTO)
		VCTOB3D->B3D_REFERE := TRBB3D->B3D_REFERE
		VCTOB3D->B3D_OBRDES := POSICIONE("B3A",1,xFilial("B3D")+TRBB3D->(B3D_CODOPE+B3D_CDOBRI),"B3A_DESCRI")
		VCTOB3D->B3D_CODOPE := TRBB3D->B3D_CODOPE
		VCTOB3D->B3D_CDOBRI := TRBB3D->B3D_CDOBRI
		VCTOB3D->B3D_CODIGO := TRBB3D->B3D_CODIGO
		VCTOB3D->B3D_REFERE := TRBB3D->B3D_REFERE
		VCTOB3D->(MsUnlock())
		TRBB3D->(DbSkip())

	EndDo

	TRBB3D->(dbCloseArea())
	RestArea(aB3A)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadB3DTmp

Preenche o arquivo temporario

@author p.drivas
@since 01/10/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function LoadB3DTmp(oTmpTab)

	Local aObrig := CENGETX3BX("B3A_TIPO")
	Local aB3A	 := B3A->(GetArea())


	While !SEEKB3D->(Eof())

		RecLock('TEMPB3D',.T.)
		TEMPB3D->B3D_FILIAL := SEEKB3D->B3D_FILIAL
		TEMPB3D->B3D_CODOPE := SEEKB3D->B3D_CODOPE
		TEMPB3D->B3D_CDOBRI := SEEKB3D->B3D_CDOBRI
		TEMPB3D->B3D_CODIGO := SEEKB3D->B3D_CODIGO
		TEMPB3D->B3D_TIPOBR := aObrig[Val(SEEKB3D->B3D_TIPOBR)][2]//X3COMBO("B3A_TIPO",B3A->B3A_TIPO)
		TEMPB3D->B3D_ANO    := SEEKB3D->B3D_ANO
		TEMPB3D->B3D_REFERE := SEEKB3D->B3D_REFERE
		TEMPB3D->B3D_VCTO   := STOD(SEEKB3D->B3D_VCTO)
		TEMPB3D->B3D_STATUS := SEEKB3D->B3D_STATUS//AllTrim(aStatus[Val(SEEKB3D->B3D_STATUS)][2])
		TEMPB3D->Ordenacao  := SEEKB3D->NEW_STATUS
		TEMPB3D->Recno      := SEEKB3D->Recno
		TEMPB3D->(MsUnlock())

		SEEKB3D->(DbSkip())

	EndDo

	SEEKB3D->(dbCloseArea())
	RestArea(aB3A)

Return