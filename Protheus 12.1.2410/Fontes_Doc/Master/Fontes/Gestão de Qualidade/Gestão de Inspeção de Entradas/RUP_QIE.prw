#INCLUDE "PRTOPDEF.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*{Protheus.doc}  RUP_QIE( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
@author thiago.rover
@version P12
@since   28/03/2022
@type function
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localizacao (pais). Ex: BRA 
*/
//-------------------------------------------------------------------
Function RUP_QIE( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	Local aSaveArea	as Array

	//cVersion  - Execucao apenas na release 12
	//cRelStart - Execucao do ajuste versões menores que 12.1.2310
	//cMode     - Execucao por grupo de empresas       
	If cVersion >= "12"
		aSaveArea := SX3->(GetArea())
		DbSelectArea("SX3")
		SX3->(DbSetOrder(2))

		QIEPicture(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

		If cRelStart < '2310' .and. cRelFinish >= '2310' .And. cMode == "1"
			QIEAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
		EndIf

		RestArea(aSaveArea)
	EndIf

Return

/*{Protheus.doc} QDOAjuX3Ti
Renomeia o titulo para 'Lote Fornec' e tambem o descritivo para 'Lote do Fornecedor' dos Campos QEK_DOCENT e QEP_DOCENT.
@author thiago.rover
@version P12
@since   28/03/2022
@type function
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002  
@param  cRelFinish - Release de chegada  Ex: 005 
@param  cLocaliz   - Localizacao (pais). Ex: BRA 
*/
Static Function QIEAjuX3Ti(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	If SX3->(DbSeek('QEK_DOCENT'))
		RecLock("SX3", .F.)
			SX3->X3_TITULO := 'Lote Fornec'
			SX3->X3_TITSPA := 'Lote provee'
			SX3->X3_TITENG := 'Suppl. lot'
			SX3->X3_DESCRIC := 'Lote do Fornecedor'
			SX3->X3_DESCSPA := 'Lote de Proveedor'
			SX3->X3_DESCENG := 'Supplier Lot'
		SX3->(MsUnlock())
	EndIf

	If SX3->(DbSeek('QEP_DOCENT'))
		RecLock("SX3", .F.)
			SX3->X3_TITULO := 'Lote Fornec'
			SX3->X3_TITSPA := 'Lote provee'
			SX3->X3_TITENG := 'Suppl. lot'
			SX3->X3_DESCRIC := 'Lote do Fornecedor'
			SX3->X3_DESCSPA := 'Lote de Proveedor'
			SX3->X3_DESCENG := 'Supplier Lot'
		SX3->(MsUnlock())
	EndIf

Return


/*/{Protheus.doc} QIEPicture
	Atualiza o picture da tabela QE8_TEXTO
	@type  Function
	@author celio.pereira
	@since 26/09/2022
	@version P12
	/*/

Static Function QIEPicture(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

	If SX3->(DbSeek('QE8_TEXTO'))
		RecLock("SX3", .F.)
			SX3->X3_PICTURE := '@!'
		SX3->(MsUnlock())
	EndIf

Return
