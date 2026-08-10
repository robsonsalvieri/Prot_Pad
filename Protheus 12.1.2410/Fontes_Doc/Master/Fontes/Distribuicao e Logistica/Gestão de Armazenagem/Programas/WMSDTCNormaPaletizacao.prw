#Include "Totvs.ch"   
#Include "WMSDTCNormaPaletizacao.ch"
//---------------------------------------------
/*/{Protheus.doc} WMSCLS0028
Função para permitir que a classe seja visualizada
no inspetor de objetos 
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//---------------------------------------------
Function WMSCLS0028()
Return Nil
//-------------------------------------------
/*/{Protheus.doc} WMSDTCNormaPaletizacao
Classe norma paletização
@author Inovação WMS
@since 16/12/2016
@version 1.0
/*/
//-------------------------------------------
CLASS WMSDTCNormaPaletizacao FROM LongNameClass
	// Data
	DATA cCodNorma
	DATA cDesNorma
	DATA cUnitiz
	DATA cDesUnit
	DATA nLastro
	DATA nCamada
	DATA nRecno
	DATA cErro
	// Controle dados anteriores
	DATA cCodNorAnt
	// Method
	METHOD New() CONSTRUCTOR
	METHOD LoadData(nIndex)
	METHOD SetCodNor(CodNorma)
	METHOD SetDesNor(cDesNorma)
	METHOD SetUnitiz(cUnitiz)
	METHOD SetLastro(nLastro)
	METHOD SetCamada(nCamada)
	METHOD GetCodNor()
	METHOD GetDesNor()
	METHOD GetUnitiz()
	METHOD GetDesUnit()
	METHOD GetLastro()
	METHOD GetCamada()
	METHOD GetErro()
	METHOD Destroy()
ENDCLASS
//-------------------------------------------
/*/{Protheus.doc} New
Método construtor
@author felipe.m
@since 23/12/2014
@version 1.0
/*/
//-------------------------------------------
METHOD New() CLASS WMSDTCNormaPaletizacao
	Self:cCodNorma  := PadR("", TamSx3("DC2_CODNOR")[1])
	Self:cDesNorma  := PadR("", TamSx3("DC2_DESNOR")[1])
	Self:cUnitiz    := PadR("", TamSx3("DC2_CODUNI")[1])
	Self:nLastro    := 0
	Self:nCamada    := 0
	Self:nRecno     := 0
	Self:cCodNorAnt := PadR("", Len(Self:cCodNorma))
Return

METHOD Destroy() CLASS WMSDTCNormaPaletizacao
	//Mantido para compatibilidade
Return Nil
//-------------------------------------------
/*/{Protheus.doc} LoadData
Cerregamento dos dados DC2
@author felipe.m
@since 23/12/2014
@version 1.0
@param nIndex, numérico, (Descrição do parâmetro)
/*/
//-------------------------------------------
METHOD LoadData(nIndex) CLASS WMSDTCNormaPaletizacao
Local lRet        := .T.
Local lCarrega    := .T.
Local aAreaAnt    := GetArea()
Local aDC2_LASTRO := TamSx3("DC2_LASTRO")
Local aDC2_CAMADA := TamSx3("DC2_CAMADA")
Local aAreaDC2    := DC2->(GetArea())
Local cAliasDC2   := Nil
Default nIndex := 1
	Do Case
		Case nIndex == 1 // DC2_FILIAL+DC2_CODNOR
			If Empty(Self:cCodNorma)
				lRet := .F.
			Else
				If Self:cCodNorma == Self:cCodNorAnt
					lCarrega := .F.
				EndIf
			EndIf
		Otherwise
			lRet := .F.	
	EndCase
	If !lRet
		Self:cErro := STR0001 // Dados para busca não foram informados!
	Else
		If lCarrega
			cAliasDC2  := GetNextAlias()
			Do Case
				Case nIndex == 1
					BeginSql Alias cAliasDC2
						SELECT DC2.DC2_CODNOR,
								DC2.DC2_DESNOR,
								DC2.DC2_CODUNI,
								DC2.DC2_LASTRO,
								DC2.DC2_CAMADA,
								DC2.R_E_C_N_O_ RECNODC2
						FROM %Table:DC2% DC2
						WHERE DC2.DC2_FILIAL = %xFilial:DC2%
						AND DC2.DC2_CODNOR = %Exp:Self:cCodNorma%
						AND DC2.%NotDel%
					EndSql
			EndCase
			TCSetField(cAliasDC2,'DC2_LASTRO','N',aDC2_LASTRO[1],aDC2_LASTRO[2])
			TCSetField(cAliasDC2,'DC2_CAMADA','N',aDC2_CAMADA[1],aDC2_CAMADA[2])
			lRet := (cAliasDC2)->(!Eof())
			If lRet
				Self:cCodNorma  := (cAliasDC2)->DC2_CODNOR
				Self:cDesNorma  := (cAliasDC2)->DC2_DESNOR
				Self:cUnitiz    := (cAliasDC2)->DC2_CODUNI
				Self:nLastro    := (cAliasDC2)->DC2_LASTRO
				Self:nCamada    := (cAliasDC2)->DC2_CAMADA
				Self:nRecno     := (cAliasDC2)->RECNODC2
				// Controle dados anteriores
				Self:cCodNorAnt := Self:cCodNorma
			EndIf
			(cAliasDC2)->(dbCloseArea())
		EndIf
	EndIf
	RestArea(aAreaDC2)
	RestArea(aAreaAnt)
Return lRet
//-----------------------------------
// Setters
//-----------------------------------
METHOD SetCodNor(cCodNorma) CLASS WMSDTCNormaPaletizacao
	Self:cCodNorma := PadR(cCodNorma, Len(Self:cCodNorma))
Return

METHOD SetDesNor(cDesNorma) CLASS WMSDTCNormaPaletizacao
	Self:cDesNorma := PadR(cDesNorma, Len(Self:cDesNorma))
Return

METHOD SetUnitiz(cUnitiz) CLASS WMSDTCNormaPaletizacao
	Self:cUnitiz := PadR(cUnitiz, Len(Self:cUnitiz))
Return

METHOD SetLastro(nLastro) CLASS WMSDTCNormaPaletizacao
	Self:nLastro := nLastro
Return

METHOD SetCamada(nCamada) CLASS WMSDTCNormaPaletizacao
	Self:nCamada := nCamada
Return
//-----------------------------------
// Getters
//-----------------------------------
METHOD GetCodNor() CLASS WMSDTCNormaPaletizacao
Return Self:cCodNorma

METHOD GetDesNor() CLASS WMSDTCNormaPaletizacao
Return Self:cDesNorma

METHOD GetUnitiz() CLASS WMSDTCNormaPaletizacao
Return Self:cUnitiz

METHOD GetLastro() CLASS WMSDTCNormaPaletizacao
Return Self:nLastro

METHOD GetCamada() CLASS WMSDTCNormaPaletizacao
Return Self:nCamada

METHOD GetErro() CLASS WMSDTCNormaPaletizacao
Return Self:cErro
