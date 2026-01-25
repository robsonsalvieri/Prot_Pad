#include 'protheus.ch'
#include 'parmtype.ch'
#include 'LOCXCOL.ch'

#Define SnTipo      1
#Define ScCliFor    2
#Define SlFormProp  3 
#Define SAliasHead  4

Static lChkLxProp := FindFunction("ChkLxProp")

/*/{Protheus.doc} LxVldEncC
Valida datos del encabezado al ejecutar la acción Doc Orig para Notas de Crédito para país Colombia.
@type
@author luis.enriquez
@since 12/03/2020
@version 1.0
@param aCfgNF, arreglo, Arreglo de datos del documento
@param cFunName, caracter, Nombre del programa en ejecución
@return lRetVld, falso si se detecto que no existe informado algún campo
@example
LxVldEncC(aCfgNF,cFunName)
@see (links_or_references)
/*/
Function LxVldEncC(aCfgNF,cFunName)
	Local cDato   := ""
	Local cCpoCli := IIf(aCfgNF[SAliasHead] == "SF1","F1_FORNECE","F2_CLIENTE")
	Local cCpoLoja:= IIf(aCfgNF[SAliasHead] == "SF1","F1_LOJA","F2_LOJA")
	Local cCpoTpO := IIf(aCfgNF[SAliasHead] == "SF1","F1_TIPOPE","F2_TIPOPE")
	Local cCliFor := IIf(aCfgNF[SAliasHead] == "SF1",M->F1_FORNECE,M->F2_CLIENTE)
	Local cLoja   := IIf(aCfgNF[SAliasHead] == "SF1",M->F1_LOJA,M->F2_LOJA)
	Local cTipOpe := IIf(aCfgNF[SAliasHead] == "SF1",M->F1_TIPOPE,M->F2_TIPOPE)
	Local cCRLF   := (Chr(13) + Chr(10))
	Local lRetVld := .T.

	If Empty(cCliFor) //Cliente
		cDato += "-" + FWX3Titulo(cCpoCli) + "(" + cCpoCli + ")" + cCRLF
	EndIf
	If Empty(cLoja) //Tienda
		cDato += "-" + FWX3Titulo(cCpoLoja) + "(" + cCpoLoja + ")" + cCRLF
	EndIf

	If cFunName == "MATA465N" .And. Empty(cTipOpe) .And. !Empty(GetMV("MV_PROVFE", .F., ""))
		cDato += "-" + FWX3Titulo(cCpoTpO) + "(" + cCpoTpO + ")" + cCRLF
	EndIf

	If !Empty(cDato) //Tienda
		MsgAlert(STR0001 + cCRLF + cDato) //"Es necesario informar los siguientes datos en el encabezado:"
		lRetVld := .F.
	EndIf
Return lRetVld

/*/{Protheus.doc} LxMIVldCO
Función que realiza validación de acuerdo al valor y nombre del campo para país Colombia.
@type
@author luis.enriquez
@since 12/03/2020
@version 1.0
@param cValCpo, caracter, Valor del campo
@param cCpo, caracter, Nombre del campo
@return lRetVld, falso si se detecta que ocurrió algun detalle con la validación del campo.
@example
LxMIVldCO(cTpRel,cCpo)
@see (links_or_references)
/*/
Function LxMIVldCO(cValCpo,cCpo)
	Local lRetVld := .T.
	Local cProvFE := SuperGetMV("MV_PROVFE", .F., "")
	Local cTpDoc  := ""
	Local cAviso  := ""

	Default cValCpo:= ""
	Default cCpo   := ""

	If !Empty(cProvFE)
		If cCpo == "F1_TIPOPE" .Or. cCpo == "F2_TIPOPE"
			If Empty(cValCpo)
				cAviso := StrTran(STR0002, '###', RTrim(FWX3Titulo(cCpo))) + " (" + cCpo + ")." //"Es necesario informar en el encabezado el campo ###"
				lRetVld := .F.
			Else
				cTpDoc := AllTrim(ObtColSAT("S017",Alltrim(cValCpo),1,4,85,3))
				cTpDoc := IIf(cTpDoc == "NF" ,"NF|RFN",cTpDoc)
				If !Empty(cTpDoc) .And. !(Alltrim(cEspecie) $ Alltrim(cTpDoc))
					cAviso := StrTran(STR0003, '###', RTrim(FWX3Titulo(cCpo))) + cCpo + STR0004 //"El campo ###( //"), no contiene un tipo de operación válido para el tipo de documento."
					lRetVld := .F.
				EndIf
			EndIf
		EndIf
	EndIf
	If !Empty(cAviso)
		Aviso(STR0005, cAviso, {STR0006}) //"Atención" //"OK"
	EndIf
Return lRetVld

/*/{Protheus.doc} LxCpoCol
Funcion utilizada para agregar campos al encabezado de
Notas Fiscales para Colombia.
@type Function
@author luis.enriquez
@since 08/08/2019
@version 1.1
@param aCposNF, Array, Array con campos del encabezado de NF
@param cFunName, Character, Codigo de rutina
@param cTablaEnc, Character, Alias del encabezado de Notas Fiscales
@example LxCpoCol(aCposNF, cFunName, cTablaEnc)
@return aCposNF, Array, Campos para el Encabezado de Notas Fiscales.
@see (links_or_references)
/*/
Function LxCpoCol(aCposNF, cFunName, cTablaEnc)

	Local cProvFE := SuperGetMV("MV_PROVFE",,"")
    Local cVld    := ""
    Local aSX3    := {}
	Local lAnexo19  := SuperGetMV("MV_ANEXO19",.F.,.F.)

    If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf
    If cTablaEnc == "SF2"
		If SF2->(ColumnPos( "F2_CODMUN" )) > 0
			aSX3 := LxSX3Cache("F2_CODMUN")
			cVld := LocX3Valid("F2_CODMUN")
			AAdd(aCposNF,{FWX3Titulo("F2_CODMUN"),"F2_CODMUN",aSX3[1],aSX3[2],aSX3[3],cVld,aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If SF2->(ColumnPos( "F2_TPACTIV" )) > 0
			aSX3 := LxSX3Cache("F2_TPACTIV")
			cVld := LocX3Valid("F2_TPACTIV")
			AAdd(aCposNF,{FWX3Titulo("F2_TPACTIV"),"F2_TPACTIV",aSX3[1],aSX3[2],aSX3[3],cVld,aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,})
		EndIf
		IF SF2->(ColumnPos( "F2_TRMPAC" )) > 0 .AND. ( cFunName $ "MATA467N|MATA462N|" )
			AAdd(aCposNF,{FWX3Titulo("F2_TRMPAC"),"F2_TRMPAC",,,,,,,"SF2",,,,,,,,,,,.T.,StrTokArr(Alltrim(X3CBox()),';'),{|x| x:nAt}})
		EndIf
		IF SF2->(ColumnPos( "F2_TIPOPE" )) > 0 .AND. ( cFunName $ "MATA467N|MATA462N|MATA465N" .Or. Alltrim(Str(aCfgNF[SnTipo],2))$"1|2" ) .And. !Empty(cProvFE)
			aSX3 := LxSX3Cache("F2_TIPOPE")
			AAdd(aCposNF,{FWX3Titulo("F2_TIPOPE"),"F2_TIPOPE",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		IF SF2->(ColumnPos( "F2_TPDOC" )) > 0 .AND. Alltrim(Str(aCfgNF[SnTipo],2))$"1|2|22|50" .And. !Empty(cProvFE)
			aSX3 := LxSX3Cache("F2_TPDOC")
			AAdd(aCposNF,{FWX3Titulo("F2_TPDOC"),"F2_TPDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If lAnexo19 .And. SF2->(ColumnPos("F2_PTOEMIS")) > 0 .AND.  cFunName$"MATA465N" .And. !Empty(cProvFE)
			aSX3 := LxSX3Cache("F2_PTOEMIS")
			AAdd(aCposNF,{FWX3Titulo("F2_PTOEMIS"),"F2_PTOEMIS", aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If cFunName $ "MATA466N"
			If  aCfgNF[1] == 22 // Nota Ajuste NCP
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F2_SERIE"})
				If nPosCpo > 0
					aCposNF[nPosCpo][16] := "01" // Consulta(SX5)
				Endif
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F2_CLIENTE"})
				If nPosCpo > 0
					aCposNF[nPosCpo][6] := aCposNF[nPosCpo][6] // Validacion de Proveedor vs Cliente
				Endif
				If SF2->(ColumnPos( "F2_TIPNOTA" )) > 0
					aSX3 := LxSX3Cache("F2_TIPNOTA")
					AAdd(aCposNF,{FWX3Titulo("F2_TIPNOTA"),"F2_TIPNOTA",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF2",aSX3[7],,,.T.,,,aSX3[8]})
				EndIf
			EndIf
		EndIf
	Else
		IF SF1->(ColumnPos("F1_CODMUN")) > 0
		    aSX3 := LxSX3Cache("F1_CODMUN")
			cVld := LocX3Valid("F1_CODMUN")
			AAdd(aCposNF,{FWX3Titulo("F1_CODMUN"),"F1_CODMUN", aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
		EndIF
		If SF1->(ColumnPos("F1_TPACTIV")) > 0 .AND. ( cFunName$"MATA465N|MATA101N|MATA466N" )
			aSX3 := LxSX3Cache("F1_TPACTIV")
			cVld := LocX3Valid("F1_TPACTIV")
			AAdd(aCposNF,{FWX3Titulo("F1_TPACTIV"),"F1_TPACTIV", aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
		EndIf
		If cFunName $ "MATA101N"
			IF SF1->(ColumnPos("F1_TRMPAC")) > 0
				AAdd(aCposNF,{FWX3Titulo("F1_TRMPAC"),"F1_TRMPAC",,,,,,,"SF1",,,,,,,,,,,.T.,StrTokArr(ALLTRIM(x3cbox()),';'),{|x| x:nAt}})
			EndIf

			If lDocSp
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_SERIE"})
				If nPosCpo > 0
					aCposNF[nPosCpo][16] := "01" // Consulta(SX5)
				Endif
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_FORNECE"})
				If nPosCpo > 0
					aCposNF[nPosCpo][6] := aCposNF[nPosCpo][6] // Validacion de Proveedor vs Cliente
				Endif
			Endif
		EndIf
		If cFunName $ "MATA466N"
			If  aCfgNF[1] == 23  // Nota Ajuste NDP
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_SERIE"})
				If nPosCpo > 0
					aCposNF[nPosCpo][16] := "01" // Consulta(SX5)
				Endif
				nPosCpo:= Ascan(aCposNF,{|x| x[2] == "F1_FORNECE"})
				If nPosCpo > 0
					aCposNF[nPosCpo][6] := aCposNF[nPosCpo][6] // Validacion de Proveedor vs Cliente
				Endif
				If SF1->(ColumnPos( "F1_TIPNOTA" )) > 0
					aSX3 := LxSX3Cache("F1_TIPNOTA")
					AAdd(aCposNF,{FWX3Titulo("F1_TIPNOTA"),"F1_TIPNOTA",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,.T.,,,aSX3[8]})
				EndIf
			EndIf
		EndIf
		IF SF1->(ColumnPos( "F1_TPDOC" )) > 0 .AND. (Alltrim(Str(aCfgNF[SnTipo],2))$"4|23" .OR. lDocSp) .And. !Empty(cProvFE)
			aSX3 := LxSX3Cache("F1_TPDOC")
			AAdd(aCposNF,{FWX3Titulo("F1_TPDOC"),"F1_TPDOC",aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,.T.,,,aSX3[8]})
		EndIf
		If lAnexo19 .And. SF1->(ColumnPos("F1_PTOEMIS")) > 0 .AND.  cFunName$"MATA465N" .And. !Empty(cProvFE)
			aSX3 := LxSX3Cache("F1_PTOEMIS")
			AAdd(aCposNF,{FWX3Titulo("F1_PTOEMIS"),"F1_PTOEMIS", aSX3[1],aSX3[2],aSX3[3],aSX3[4],aSX3[5],aSX3[6],"SF1",aSX3[7],,,,,,aSX3[8]})
		EndIf
		
	EndIf

Return aCposNF

/*/{Protheus.doc} LxSX3Cache
Función para obtener datos del SX3 para campos usando la función GetSX3Cache
@type
@author luis.enriquez
@since 18/03/2020
@version 1.0
@param cCampo, caracter, Nombre del campo.
@return aSX3Cpos, array, Arreglo con contenido de la tabla SX3 para el campo.
@see (links_or_references)
/*/
Function LxSX3Cache(cCampo)
	Local aSX3Cpos := {}

	Default cCampo := ""

	If !Empty(cCampo)
		aSX3Cpos := {GetSX3Cache(cCampo,"X3_PICTURE"), ; //1
		GetSX3Cache(cCampo,"X3_TAMANHO"), ; //2
		GetSX3Cache(cCampo,"X3_DECIMAL"), ; //3
		GetSX3Cache(cCampo,"X3_VALID"), ;   //4
		GetSX3Cache(cCampo,"X3_USADO"), ;   //5
		GetSX3Cache(cCampo,"X3_TIPO"), ;    //6
		GetSX3Cache(cCampo,"X3_CONTEXT"), ; //7
		GetSX3Cache(cCampo,"X3_F3")}        //8
	EndIf
Return aSX3Cpos

/*/{Protheus.doc} LxVldFact
Función para validar el borrado TSS de la factura para el pais Colombia
@type
@author eduardo.manriquez
@since 24/06/2020
@version 1.0
@param cAlias, caracter, Alias de la tabla.
@see (links_or_references)
/*/
Function LxVldFact(cAlias, lNotAjus)
	Local lRet := .T.
	Default cAlias := ""
	Default lNotAjus := .F.

	If cAlias == "SF2" .And. SF2->(ColumnPos("F2_FLFTEX"))>0
		If Val(SF2->F2_FLFTEX) == 6 .OR. !Empty(SF2->F2_FLFTEX)
			//"La factura Serie y No. "###"no puede ser borrada pues ya fue procesada por la Transmisión Electrónica. Utilice la opción Anular"  ###"¡TSS: Transmisión Electrónica !"
			If !lNotAjus
				MsgAlert( STR0007 + " " + SF2->F2_SERIE + SF2->F2_DOC + STR0008 , STR0010 )
			Else
				//"La Nota de Ajuste"//" no puede ser borrada. El Documento ya fue autorizada por la DIAN.."//"Transmisión Electrónica"
				MsgAlert( STR0032 + " " + SF2->F2_SERIE + SF2->F2_DOC + STR0033  , STR0034 )
			Endif
			lRet := .F.
		EndIf
	ElseIf cAlias <> "SF2" .And. SF1->(ColumnPos("F1_FLFTEX"))>0
		If Val(SF1->F1_FLFTEX) == 6 .OR. !Empty(SF1->F1_FLFTEX)
			//"La factura Serie y No. "###"no puede ser borrada pues ya fue procesada por la Transmisión Electrónica. Utilice la opción Anular"  ###"¡TSS: Transmisión Electrónica !"
			If !lNotAjus
				MsgAlert( STR0007 + " " + SF1->F1_SERIE + SF1->F1_DOC + STR0009 , STR0010 )
			Else
				//"La Nota de Ajuste"//" no puede ser borrada. El Documento ya fue autorizada por la DIAN.."//"Transmisión Electrónica"
				MsgAlert( STR0032 + " " + SF1->F1_SERIE + SF1->F1_DOC + STR0033 , STR0034 )
			Endif
			lRet := .F.
		EndIf
	Endif
Return lRet

/*/{Protheus.doc} M030AltCV0
Funcion utilizada en la rutina de Clientes para actualizar
o incluir valores en tabla CV0 (MATN030).
@type Function
@author Marco Augusto Gonzalez Rivera
@since 30/07/2020
@version 1.0
@param lIncReg, Lógico, Indica si es inclusión o modificación.
/*/
Function M030AltCV0(lIncReg)

	Local aArea		:= GetArea()
	Local cAliasCV0	:= GetNextAlias()
	Local nRecnoCV0	:= 0
	Local nReg      := 0
	Local cItm      := ""
	Local cEntSup := Alltrim(SuperGetMV("MV_ENTSCLI ",.T.,"13"))

	cEntSup := iif(Empty(cEntSup),"13",cEntSup)
	If lIncReg
		BeginSQL Alias cAliasCV0
				SELECT CV0.R_E_C_N_O_
				FROM %table:CV0% CV0
				WHERE CV0.CV0_FILIAL = %xfilial:CV0% AND
					CV0.CV0_CODIGO = %Exp:cEntSup% AND
					CV0.%notDel%
		EndSQL
		Count to nReg
		(cAliasCV0)->(DBCloseArea())
		If nReg == 0
			DBSelectArea("CV0")
			cItm := GetSxENum( "CV0", "CV0_ITEM" )
			RecLock("CV0",.T.)
			CV0->CV0_FILIAL	:=xFilial("CV0")
			CV0->CV0_PLANO	:="01"
			CV0->CV0_ITEM		:=cItm
			CV0->CV0_CODIGO 	:= cEntSup
			CV0->CV0_CLASSE  	:= "1"
			CV0->CV0_NORMAL 	:= "1"
			CV0->CV0_DTIEXI 	:= dDatabase
			CV0->CV0_BLOQUE 	:= "2"
			CV0->CV0_DESC   	:= STR0013 // "Clientes"
			CV0->(MsUnlock())
			ConfirmSX8()
		EndIf
		DBSelectArea("CV0")
		cItm := GetSxENum( "CV0", "CV0_ITEM" )
		Begin Transaction
			RecLock("CV0", .T.)
			CV0->CV0_FILIAL 	:= xFilial("CV0")
			CV0->CV0_CODIGO 	:= IIf(AllTrim(M->A1_TIPDOC) == "31", M->A1_CGC, M->A1_PFISICA)
			CV0->CV0_PLANO  	:=	"01"
			CV0->CV0_ITEM		:=	cItm
			CV0->CV0_CLASSE 	:= "2"
			CV0->CV0_NORMAL 	:= "1"
			CV0->CV0_ENTSUP 	:= cEntSup
			CV0->CV0_DTIEXI 	:= dDatabase
			CV0->CV0_TIPO00 	:= "01"
			CV0->CV0_TIPO01 	:= M->A1_TIPDOC
			CV0->CV0_DESC		:= M->A1_NOME
			CV0->CV0_COD		:= M->A1_COD
			CV0->CV0_LOJA		:= M->A1_LOJA
			CV0->(MsUnlock())
			ConfirmSX8()
		End Transaction
	Else
		BeginSQL Alias cAliasCV0
			SELECT CV0.R_E_C_N_O_
			FROM %table:CV0% CV0
			WHERE CV0.CV0_FILIAL = %xfilial:CV0% AND
				CV0.CV0_COD = %Exp:M->A1_COD% AND
				CV0.CV0_LOJA = %Exp:M->A1_LOJA% AND
				CV0.CV0_TIPO00 = '01' AND
				CV0.%notDel%
		EndSQL

		nRecnoCV0 := (cAliasCV0)->(R_E_C_N_O_)

		If nRecnoCV0 > 0
			DBSelectArea("CV0")
			CV0->(DBGoTo(nRecnoCV0))
			RecLock("CV0", .F.)
			CV0->CV0_DESC	:= M->A1_NOME
			CV0->CV0_COD	:= M->A1_COD
			CV0->CV0_LOJA	:= M->A1_LOJA
			CV0->CV0_CODIGO := IIf(AllTrim(M->A1_TIPDOC) == "31", M->A1_CGC, M->A1_PFISICA)
			CV0->CV0_TIPO01 := M->A1_TIPDOC
			CV0->(MsUnlock())
		EndIf

		(cAliasCV0)->(DBCloseArea())

	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} M030ValMov
Funcion utilizada en la rutina de Clientes para validar
si existen movimientos contables antes de actualizar CV0(MATN030).
@type Function
@author Oscar García López
@since 27/10/2020
@version 1.0
@param cCodigo, caracter, codigo cliente.
@param cLoja, caracter, tienda cliente.
@return lExist, lógico, Indica si existen o no movimientos contables para el tipo del documento del cliente.
/*/
Function M030ValMov(cCodigo, cLoja)

	Local lExist	:= .F.
	Local cBusca	:= ""
	Local lDif		:= .F.
	Local cNIT		:= ""
	Local cPFis		:= ""
	Local aArea		:= GetArea()

	Default cCodigo := ""
	Default cLoja := ""

	DBSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	If SA1->(MsSeek(xFilial("SA1") + cCodigo + cLoja))
		cNIT		:= Alltrim(SA1->A1_PFISICA)
		cPFis		:= Alltrim(SA1->A1_CGC)

		If AllTrim(SA1->A1_TIPDOC) == "31"
			lDif	:= !(cPFis == Alltrim(M->A1_CGC))
			cBusca	:= cPFis
		Else
			lDif	:= !(cNIT == Alltrim(M->A1_PFISICA))
			cBusca	:= cNIT
		EndIf

		If lDif
			cAliasMov := GetNextAlias()
			BeginSQL Alias cAliasMov
				SELECT CT2.R_E_C_N_O_
				FROM %table:CT2% CT2
				WHERE CT2.CT2_FILIAL = %xfilial:CT2% AND
					( CT2_EC05DB = %Exp:cBusca% OR
					CT2_EC05CR = %Exp:cBusca% )
			EndSQL

			If (cAliasMov)->(R_E_C_N_O_) > 0
				lExist := .T.
			EndIf
			(cAliasMov)->(DBCloseArea())

			If !lExist
				cAliasMov := GetNextAlias()
				BeginSQL Alias cAliasMov
					SELECT CVX.R_E_C_N_O_
					FROM %table:CVX% CVX
					WHERE CVX.CVX_FILIAL = %xfilial:CVX% AND
						CVX_NIV05 = %Exp:cBusca%
				EndSQL

				If (cAliasMov)->(R_E_C_N_O_) > 0
					lExist := .T.
				EndIf
				(cAliasMov)->(DBCloseArea())
			EndIf

			If !lExist
				cAliasMov := GetNextAlias()
				BeginSQL Alias cAliasMov
					SELECT CVY.R_E_C_N_O_
					FROM %table:CVY% CVY
					WHERE CVY.CVY_FILIAL = %xfilial:CVY% AND
						CVY_NIV05 = %Exp:cBusca%
				EndSQL

				If (cAliasMov)->(R_E_C_N_O_) > 0
					lExist := .T.
				EndIf
				(cAliasMov)->(DBCloseArea())
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lExist

/*/{Protheus.doc} M020AltCV0
	Función que realiza la inclusión, modificación y elimicación de los registro en la
	tabla CV0 del proveedor.
	@type  Function
	@author eduardo.manriquez
	@since 18/05/2022
	@version 1.0
	@param nOpc, Númerico, Opción del modelo que se esta ejecutando, 3 - Insersión, 4 - Edición y 5 - Eliminación.
	@param cCodigo, Caracter, Código del proveedor.
	@return
	@example
	M020AltCV0(nOpc,cCodigo)
	/*/
Function M020AltCV0(nOpc,cCodigo)
    Local cItm := ""
    Local cEntSup := Alltrim(SuperGetMV("MV_ENTSPRO",.T.,"22"))
	Local cAliasCV0 := ""
	Local nReg      := 0
	Default cCodigo := ""

	cEntSup := iif(Empty(cEntSup),"22",cEntSup)
	If nOpc == 3
		Begin Transaction
			cAliasCV0 := GetNextAlias()
			BeginSQL Alias cAliasCV0
				SELECT CV0.R_E_C_N_O_
				FROM %table:CV0% CV0
				WHERE CV0.CV0_FILIAL = %xfilial:CV0% AND
					CV0.CV0_CODIGO = %Exp:cEntSup% AND
					CV0.%notDel%
			EndSQL
			Count to nReg
			(cAliasCV0)->(DBCloseArea())
			If nReg == 0
				DBSelectArea("CV0")
				cItm := GetSxENum( "CV0", "CV0_ITEM" )
				RecLock("CV0",.T.)
				CV0->CV0_FILIAL	:=xFilial("CV0")
				CV0->CV0_PLANO	:="01"
				CV0->CV0_ITEM		:=cItm
				CV0->CV0_CODIGO 	:= cEntSup
				CV0->CV0_CLASSE  	:= "1"
				CV0->CV0_NORMAL 	:= "2"
				CV0->CV0_DTIEXI 	:= dDatabase
				CV0->CV0_BLOQUE 	:= "2"
				CV0->CV0_DESC   	:= STR0014 // "Proveedores"
				CV0->(MsUnlock())
				ConfirmSX8()
			EndIf
			DBSelectArea("CV0")
			cItm := GetSxENum( "CV0", "CV0_ITEM" )
			RecLock("CV0",.T.)
			CV0->CV0_FILIAL	:=xFilial("CV0")
			CV0->CV0_PLANO	:="01"
			CV0->CV0_ITEM		:=cItm
			CV0->CV0_CODIGO 	:= IIF(M->A2_TIPDOC=="31",M->A2_CGC,M->A2_PFISICA)
			CV0->CV0_CLASSE  	:= "2"
			CV0->CV0_NORMAL 	:= "2"
			CV0->CV0_ENTSUP 	:= cEntSup
			CV0->CV0_DTIEXI 	:= dDatabase
			CV0->CV0_TIPO00 	:= "02"
			CV0->CV0_DESC   	:= M->A2_NOME
			CV0->CV0_TIPO01 	:= M->A2_TIPDOC
			CV0->CV0_COD   	:= M->A2_COD
	   		CV0->CV0_LOJA  	:= M->A2_LOJA
			CV0->(MsUnlock())
			ConfirmSX8()
		End Transaction

	ElseIf nOpc == 4
		DbSelectArea("CV0")
		DbSetOrder(4)//CV0_FILIAL+CV0_COD+CV0_TIPO00+CV0_CODIGO
		If DbSeek(xFilial("CV0")+M->A2_COD+'02'+M->A2_CGC) .OR. DbSeek(xFilial("CV0")+M->A2_COD+'02'+M->A2_PFISICA)
			RecLock("CV0",.F.)
			CV0->CV0_DESC	:= M->A2_NOME
			CV0->CV0_COD	:= M->A2_COD
		   	CV0->CV0_LOJA	:= M->A2_LOJA
		  	CV0->(MsUnlock())
		Elseif DbSeek(xFilial("CV0")+M->A2_COD+'02')
			RecLock("CV0",.F.)
			CV0->CV0_DESC	:= M->A2_NOME
			CV0->CV0_COD	:= M->A2_COD
		   	CV0->CV0_LOJA	:= M->A2_LOJA
		   	CV0->CV0_CODIGO := IIF(M->A2_TIPDOC=="31",M->A2_CGC,M->A2_PFISICA)
		   	CV0->CV0_TIPO01 	:= M->A2_TIPDOC
		   	CV0->(MsUnlock())
		EndIf

	ElseIf nOpc == 5
		DbSelectArea("CV0")
		DbSetOrder(4)//CV0_FILIAL+CV0_COD+CV0_TIPO00+CV0_CODIGO
		If DbSeek(xFilial("CV0")+cCodigo+'02'+M->A2_CGC) .OR. DbSeek(xFilial("CV0")+cCodigo+'02'+M->A2_PFISICA)
			RecLock("CV0",.F.)
			CV0->(dbDelete())
		   	CV0->(MsUnlock())
		EndIf
	EndIf

Return


/*/{Protheus.doc} xGrvCabCOL
	Actualiza campos del encabezado especificos para Colombia.
	La función es ejecutada desde LOCXNF, función GravaCabNF.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	aCabNota: Array con campos y valores valores de encabezado
			nI: Posición del campo en aCabNota
	@return Nil
	/*/
Function xGrvCabCOL(aCabNota, nI)
Default aCabNota := {}
Default nI       := 0

	If aCabNota[1][nI] $ "F1_TRMPAC|F2_TRMPAC|"
		Replace &(aCabNota[1][nI]) With CVALTOCHAR(aCabNota[2][nI])
	Else
		Replace &(aCabNota[1][nI]) With aCabNota[2][nI]
	Endif

Return

/*/{Protheus.doc} xGrvImpCol
	Graba información de impuestos para Colombia.
	La función es ejecutada desde LOCXNF, función GravaImposto.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasC: Alias tabla (SF1/SF2)
			nPosPed: Posición del campo D1_PEDIDO en aHeader
			nCodPro: Posición del campo D1_COD en aHeader
			nPosCF:  Posición del campo D1_CF en aHeader
			cFilSB1: Filial de tabla SB1
			aCols:   Array de ítems de documento fiscal
			nZ:      Número de ítem en aCols
	@return Nil
	/*/
Function xGrvImpCol(cAliasC, nPosPed, nCodPro, nPosCF, cFilSB1, aCols, nZ)
Local lPedido 	:= .F.

Default cAliasC := ""
Default nCodPro := 0
Default nPosCF  := 0
Default cFilSB1 := ""
Default aCols   := {}
Default nZ      := 0

	If nPosPed <> 0
		lPedido:= !Empty(aCols[nZ][nPosPed])
	Endif
	If cAliasC == 'SF1' .And. lPedido
		If nCodPro > 0
			SB1->(MsSeek(cFilSB1 + aCols[nZ][nCodPro]))
		EndIf
		MafisAlt('IT_CF', aCols[nZ][nPosCF], nZ)
	EndIf
Return

/*/{Protheus.doc} xCliForCol
	Actualiza información de campos de encabezado SF1/SF2.
	La función es ejecutada desde LOCXNF, función AtuCliFor.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	aCfgNf: Array de configuración para nota fiscal
			cTASARTF: Valor del campo F1_TASARFT
	@return Nil
	/*/
Function xCliForCol(aCfgNf, cTASARTF)
Local cMunic   := ""
Local cActiv   := ""
Local nPorBase := 0.0

Default aCfgNf   := {}
Default cTASARTF := ""

	If Type("aCfgNf") == "A"
		If	SF2->(FieldPos("F2_CODMUN")) > 0
			If aCfgNf[ScCliFor]=="SA2"
				cMunic := SA2->A2_COD_MUN
			Else
				cMunic := SA1->A1_COD_MUN
			Endif
			If aCfgNf[SAliasHead] == "SF2"
				M->F2_CODMUN := cMunic
			Else
				M->F1_CODMUN := cMunic
			Endif
			MaFisAlt("NF_CODMUN",cMunic)
		EndIf
		If	SF2->(FieldPos("F2_TPACTIV")) > 0
			If aCfgNf[ScCliFor]=="SA2"
				cActiv := SA2->A2_CODICA
			Else
				cActiv := SA1->A1_ATIVIDA
			Endif
			If aCfgNf[SAliasHead] == "SF2"
				M->F2_TPACTIV := cActiv
			Else
				M->F1_TPACTIV := cActiv
			Endif
			MaFisAlt("NF_TPACTIV",cActiv)
		EndIf

		If  aCfgNf[ScCliFor]=="SA2"
			nPorBase := SA2->A2_TASARFT
		Endif
		If aCfgNf[SAliasHead] == "SF1"
			M->F1_TASARFT := nPorBase
			cTASARTF      := nPorBase
		Endif
	EndIf
Return

/*/{Protheus.doc} xObtCFOCol
	Obtiene código fiscal de TES o funciones de automatización de TES.
	La función es ejecutada desde LOCXNF (función LxDocOri) y LOCXNF2 (función LxA103SD2ToaCols).
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	lAutTES: Identica si utiliza funcionalidad de automatización de TES (MV_AUTTES = .T.)
			cCliFor: Código de cliente o proveedor.
			cLoja: Código de loja de cliente o proveedor.
			cCodProd: Código de producto.
			cTES: Código de TES.
			aHeader: Array de campos SD1/SD2.
			aCols: Array de ítems de documento fiscal.
			nItem: Item de nota fiscal.
			nPosCFO: Posición de campo D1_CF en aHeader.
			nPosTes: Posición de campo D1_TES en aHeader.
	@return cCFO - Código Fiscal
	/*/
Function xObtCFOCol(lAutTES, cCliFor, cLoja, cCodProd, cTES, aHeader, aCols, nItem, nPosCFO, nPosTes, lMaFisAlt, cEspecie)
Local cCFO     := ""
Local aAreaSF4 := {}
Local cCpoCF   := ""
Local cCpoTES  := ""

Default lAutTES  := .T.
Default cCliFor  := ""
Default cLoja    := ""
Default cCodProd := ""
Default cTES     := ""
Default aHeader  := {}
Default aCols    := {}
Default nItem    := 0
Default nPosCFO  := 0
Default nPosTes  := 0
Default lMaFisAlt := .F.
Default cEspecie  := ""

	If nPosCFO == 0
		cCpoCF := IIf(cEspecie=="NDC",'D2_CF','D1_CF')
		nPosCFO := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpoCF})
	EndIf
	If Empty(cTES)
		cCpoTES  := IIf(cEspecie=="NDC",'D2_TES','D1_TES')
		nPosTes := Ascan(aHeader,{|x| Alltrim(x[2]) == cCpoTES})
		cTES    := IIf(nPosTes>0,aCols[nItem][nPosTes],"")
	EndIf

	If lAutTES
		cCFO := LxTESAutoCOL(cCliFor, cLoja, cCodProd, "CF", IIf(cEspecie=="NDC","SD2","SD1"))
	Else
		aAreaSF4 := SF4->(GetArea())
		cCFO := Posicione("SF4",1,xFilial("SF4")+cTES,"F4_CF")
		RestArea(aAreaSF4)
	EndIf

	// Conservar CF asignado por automatización de TES o definido por el usuario
	IIf(lMaFisAlt, MaFisAlt("IT_CF", cCFO, nItem), .T.)
	aCols[nItem][nPosCFO] := cCFO

Return cCFO

/*/{Protheus.doc} xValDupCol
	Obtiene código fiscal de TES o funciones de automatización de TES.
	La función es ejecutada desde LOCXNF2, funciones ValDuplic/LxA103Dupl.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	nValor: Valor del título financiero
			aHeader: Array de campos SD1/SD2.
			aCols: Array de ítems de documento fiscal.
			lA103Dupl: Flag para identificar origen de llamada de función.
	@return nValor: Valor de título financiero.
	/*/
Function xValDupCol(nValor, aHeader, acols, lA103Dupl)
Local nx         := 0
Local nPospd     := 0
Local cJNs       := ""
Local nValRetImp := 0
Local cFilSFC	 := xFilial("SFC")
Local cFunName   := FunName()

Default nValor    := 0
Default aHeader   := {}
Default acols     := {}
Default lA103Dupl := .F.

	dbSelectArea("SFC")
	dbSetOrder(2)

	SFB->(DbSeek(xFilial("SFB")+"RV0"))
	For nx:=1 to Len(acols)
		nPospd:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"} )
		If nPospd==0
			nPospd:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"} )
		EndIf

		If !acols[nx][Len(acols[1])] .And. !Empty(acols[nx][nPospd])

			If SFC->(MsSeek(cFilSFC + MaFisRet(Nx,"IT_TES")+ "RV0")) //Retenção IVA
					SFB->(DbSeek(xFilial("SFB")+"RV0"))

					If SFC->FC_INCDUPL == '2'
							nValRetImp 	+= (MaFisRet(Nx,"IT_VALIV2") )
					ElseIf SFC->FC_INCDUPL == '1'
							nValRetImp -= MaFisRet(Nx,"IT_VALIV2")
					EndIf

					cJNs:=SFB->FB_JNS
			EndIf
			If SFC->(MsSeek(cFilSFC + MaFisRet(Nx,"IT_TES")+ "RF0")) //Retenção TIMBRE
					SFB->(DbSeek(xFilial("SFB")+"RF0"))

					If SFC->FC_INCDUPL == '2'
							nValRetImp 	+= (MaFisRet(Nx,"IT_VALIV4") )
					ElseIf SFC->FC_INCDUPL == '1'
							nValRetImp -= MaFisRet(Nx,"IT_VALIV4")
					EndIf

					cJNs := SFB->FB_JNS
			EndIf
			If SFC->(MsSeek(cFilSFC + MaFisRet(Nx,"IT_TES")+ "RC0")) //Retenção ICA
				SFB->(DbSeek(xFilial("SFB")+"RC0"))

				If SFC->FC_INCDUPL == '2'
					nValRetImp 	+= (MaFisRet(Nx,"IT_VALIV7") )
				ElseIf SFC->FC_INCDUPL == '1'
					nValRetImp -=  MaFisRet(Nx,"IT_VALIV7")
				EndIf
				cJNs := SFB->FB_JNS
			EndIf
		EndIf
	Next
	If !lA103Dupl
		If cFunName $ "MATA101N" .Or. (lChkLxProp .and. ChkLxProp("SumaRetImpCol"))
			nValor := nValor + nValRetImp
		Else
			If cJNs $ 'J|S'
				nValor := nValor + nValRetImp
			Endif
		Endif
	Else
		nValor := nValor + nValRetImp
	EndIf

Return (nValor)

/*/{Protheus.doc} VdDocItCol
	Valida documento informado en D2_NFORI/D1_NFORI con serie en D2_SERIORI/D1_SERIORI para NDC/NCC - Colombia.
	La función es ejecutada desde LOCXNF2, función LxVldDocIt.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cNumeroDoc: Número de documento.
			cSerie: código de serie.
			cEspecie: Código de especie de documento.
			lM485PE: Flag de punto de entrada M465DORIFE. Si es .F. no realiza todas las validaciones.
	@return lRet: Identificar si cumple las condiciones.
	/*/
Function VdDocItCol(cNumeroDoc, cSerie, cEspecie, lM485PE)
Local lRet	   := .T.
Local aArea	   := GetArea()
Local cTipoFE  := SuperGetMV("MV_TIPOFE",,"")
Local cCpoSerO := IIf(cEspecie=="NDC","D2_SERIORI","D1_SERIORI")
Local cCpoDocO := IIf(cEspecie=="NDC","D2_NFORI","D1_NFORI")
Local cTipOpe  := IIf(cEspecie=="NDC",M->F2_TIPOPE,M->F1_TIPOPE)
Local cVldD    := ""
Local lValFE   := .T.
Local cCliForE := IIf(cEspecie=="NDC",M->F2_CLIENTE,M->F1_FORNECE)
Local cLojaE   := IIf(cEspecie=="NDC",M->F2_LOJA,M->F1_LOJA)

Default cNumeroDoc	:= ""
Default cSerie		:= ""
Default cEspecie	:= ""
Default lM485PE     := .T.

	cVldD  := AllTrim(ObtColSAT("S017",cTipOpe,1,4,88,1))
	lValFE := IIf(!Empty(cTipOpe) .And. (cVldD $ "1|2" .Or. !(cVldD $ "0|1|2")),.T.,.F.)

	If lM485PE
		If !Empty(cNumeroDoc) .And. !Empty(cSerie)
			dbSelectArea("SF2")
			SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(MsSeek(xFilial("SF2") + cNumeroDoc + cSerie + cCliForE + cLojaE))
				If lValFE
					If !(!Empty(SF2->F2_UUID) .And. (SF2->F2_FLFTEX == "1" .Or. (cTipoFE == "1" .And. SF2->F2_FLFTEX == "6")))
						MsgAlert(STR0015 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + STR0017) //"El documento original informado en el detalle (" //"), no se encuentra transmitido. Realice la transmisión e intente nuevamente."
						lRet := .F.
					Else
						If cVldD == "2" .And. Len(Alltrim(SF2->F2_UUID)) <> 40
							MsgAlert(StrTran(STR0021, '###', cSerie + "-" + cNumeroDoc)) //"UUID del documento origen (###) no pertenece al modelo de Facturación Electrónica de Validación Posterior."
							lRet := .F.
						ElseIf cVldD == "1" .And. Len(Alltrim(SF2->F2_UUID)) <> 96
							MsgAlert(StrTran(STR0022, '###', cSerie + "-" + cNumeroDoc)) //"UUID del documento origen (###) no pertenece al modelo de Facturación Electrónica de Validación Previa."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			Else
				MsgAlert(STR0015 + AllTrim(cSerie) + "-" + AllTrim(cNumeroDoc) + StrTran(STR0016, '###', AllTrim(cCliForE) + "-" + AllTrim(cLojaE))) //"El documento original informado en el detalle (" //"), no existe para el cliente ###. Informe otro e intente nuevamente."
				lRet := .F.
			EndIf
		Else
			If lValFE
				MsgAlert(STR0018 + RTrim(FWX3Titulo(cCpoDocO)) + "(" + cCpoDocO + ") " + STR0019 + RTrim(FWX3Titulo(cCpoSerO)) + "(" + cCpoDocO + ") " + STR0020) //"Los campos " - " y " - ", deben ser informados en el detalle."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} x2M030COL
	Función para agregar acciones en modificación de clientes - Colombia.
	La función es ejecutada desde LOCXNF2, función Lx2M030CO.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	aButtons - Array con opciones. La variable se pasa por referencia (@aButtons)
	@return Nil.
	/*/
Function x2M030COL(aButtons)
Default aButtons := {}

	If !Empty(SuperGetMV("MV_PROVFE",,""))
		Aadd(aButtons,{"", { || FISA827( "SA1", SA1->(RecNo()), 4, 1) } ,STR0023}) //"Resp. Obligaciones DIAN"
		Aadd(aButtons,{"", { || FISA827( "SA1", SA1->(RecNo()), 4, 2) } ,STR0024}) //"Tributos DIAN"
	EndIf
Return

/*/{Protheus.doc} xVldCpoCol
	Valida campos para el país Colombia.
	La función es ejecutada desde LOCXNF2, función LxVldCol.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasSF: Alias de tabla (SF1/SF2)
	@return Nil.
	/*/
Function xVldCpoCol(cAliasSF)
Local lRetVld	:= .T.
Default cAliasSF := ""

	If cAliasSF == "SF1"
		lRetVld := ValRetSat(M->F1_TIPOPE, "F1_TIPOPE")
	ElseIf cAliasSF == "SF2"
		lRetVld := ValRetSat(M->F2_TIPOPE, "F2_TIPOPE")
	EndIf
Return lRetVld

/*/{Protheus.doc} ColExSer2
	Actualiza campo de serie 2 (F1_SERIE2/F2_SERIE2).
	La función es ejecutada desde LOCXNF2, función LxExSer2.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	N/A
	@return .T.
	/*/
Function ColExSer2()
Local aArea    := GetArea()
Local cVarAct  := readvar()
Local cOp      := "1"
Local cFunName := FunName()

	If  ((FunName() $ 'MATA101N|MATA466N') .Or. (lChkLxProp .and. ChkLxProp("ActualizaSerie2"))) .and. FINDFUNCTION( 'LxSer2DsNa' )
		LxSer2DsNa(cVarAct, aCfgNF[1])
	ENDIF

	If cFunName $ 'MATA467N/MATA462N'
		cOp := IIF(cFunName $ 'MATA462N',"6","1")
		SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
		If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //factura de Venta
			If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+cOp))
				M->F2_SERIE2:= SFP->FP_SERIE2
			Else
				M->F2_SERIE2:= ''
			EndIf
		Endif
	EndIf
	IF cFunName $ 'MATA465N'//  Nota de Debito/Credito
		SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
				If ALLTRIM(cVaract) $ "M->F1_DOC/M->F1_SERIE"  //NCC  CREDITO

				If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F1_SERIE+('2') ))
							M->F1_SERIE2:= SFP->FP_SERIE2
					Else
							M->F1_SERIE2:= ''
					EndIf
				Else
					If ALLTRIM(cVaract) $ "M->F2_DOC/M->F2_SERIE" //NDC  DEBITO

						IF SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+M->F2_SERIE+('3') ))
								M->F2_SERIE2:= SFP->FP_SERIE2
							Else
								M->F2_SERIE2:= ''
							EndIf
					Endif
				EndIf
	EndIf
	RestArea(aArea)

Return .T.

/*/{Protheus.doc} fSerDocCol
	Validación de serie y núemro de documento, asignación de SERIE2.
	La función es ejecutada desde LOCXNF2, función fValSerDoc.
	La función fValSerDoc es ejecutada por diccionario de datos, motivo por el cuál no se paso en los parámetros la variable lDocSp.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	N/A
	@return lRet: .T. si cumple las condiciones.
	/*/
Function fSerDocCol()
Local lRet := .T.
Local cFunName := IIf(Type("cFunName")=="U",Upper(Alltrim(FunName())),IIF(Empty(cFunName),Upper(Alltrim(FunName())),cFunName))
Local cAliasSF1 := ""
Local cCampo := ""
Local nReg := 0
Local cCampoRead := ReadVar()
Local lChkNumNF	:= FindFunction("LxChkNumNF")
Local nUpdNum := SuperGetMV("MV_ALTNUM",,1)
Local cNFiscal := ""
Local lExist := .T.
Local cNumAnt := ""
Local lSX5Comp := (FwModeAccess("SX5",3) == "C")	// Tabla SX5 compartida a nivel sucursal?
Local cWhereFil := ""

	If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf

	If cFunName == "MATA465N" .OR. (cPaisloc =="COL" .AND. (lDocSp .OR. aCfgNF[1]==23) .AND. (cFunName $ "MATA101N|MATA466N" .Or. (lChkLxProp .and. ChkLxProp("DocumentoSoporte"))) )
		lRet := ( CtrFolios(xFilial("SF1"),M->F1_SERIE,M->F1_ESPECIE,M->F1_DOC) .AND. LXEXSER2())
	Endif

	If lRet .And. (lDocSp .Or. aCfgNF[1]== 23) .And. (cFunName $ "MATA101N|MATA466N" .or. (lChkLxProp .and. ChkLxProp("DocumentoSoporte"))) .And. !Empty(M->F1_DOC)
		// Validar que no se duplique Documento Soporte / NDP-Nota de ajuste
		cAliasSF1 := GetNextAlias()
		cCampo := IIf( lDocSp, "%F1_SOPORT = 'S'%", IIf(aCfgNF[1]==23, "%F1_TIPODOC = '23'%", "%F1_MARK = 'S'%" ))
		cWhereFil := IIf(lSX5Comp, "% 1=1 %", "% SF1.F1_FILIAL = '" + xFilial("SF1") + "' %" )

		BeginSQL Alias cAliasSF1
			%noparser%
			SELECT SF1.R_E_C_N_O_
			FROM %table:SF1% SF1
			WHERE %Exp:cWhereFil% AND
				SF1.F1_SERIE = %exp:M->F1_SERIE% AND
				SF1.F1_DOC = %exp:M->F1_DOC% AND
				SF1.%exp:cCampo% AND
				SF1.%notDel%
		EndSQL

		Count to nReg
		(cAliasSF1)->(DBCloseArea())

		If nReg > 0
			If cCampoRead == "M->F1_SERIE" .And. nUpdNum == 3
				lRet := .T. //si el número doc existe, se retorna .T. para que permita salir del campo F1_SERIE y permita modificar el número Doc F1_DOC

			ElseIf (nUpdNum == 1 .Or. nUpdNum == 2)
				// Ya existe el número de documento de la serie, buscar el folio más alto
				cNFiscal := M->F1_DOC

				BeginSql Alias cAliasSF1
					%noparser%
					SELECT MAX(F1_DOC) NUMDOC
					FROM %table:SF1% SF1
					WHERE %Exp:cWhereFil% AND
						SF1.F1_SERIE = %exp:M->F1_SERIE% AND
						SF1.%notDel%
				EndSql

				If !(cAliasSF1)->(Eof())
					If !Empty((cAliasSF1)->NUMDOC)
						cNFiscal := (cAliasSF1)->NUMDOC
					EndIf
				EndIf

				(cAliasSF1)->(DBCloseArea())

				While lExist
					cNFiscal := Soma1(cNFiscal)
					lExist   := !aNumNaoExiste("SF1", M->F1_SERIE, cNFiscal, M->F1_FORNECE, M->F1_LOJA, M->F1_ESPECIE, "DCS")
				EndDo

				If nUpdNum == 1 //Realiza la actualización de la numeración.
					cNumAnt := M->F1_DOC
					M->F1_DOC := cNFiscal
					MsgInfo(STR0039 + cNumAnt + STR0040 + cNFiscal, STR0041) //El número del documento fue modificado de: #  a:  # Número

				ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualización de la numeración.
					lRet := MsgYesNo(STR0042 + M->F1_DOC + STR0043 + cNFiscal  ) //El documento Nº:  #  existe, confirma modificación de la numeración a:
					If lRet
						M->F1_DOC := cNFiscal
					EndIf

				EndIf	//nUpdNum == 3 - No realiza la actualización de la numeración, envía mensaje

			EndIf

		ElseIf cCampoRead == "M->F1_DOC" .And. lChkNumNF
			// Valida que no haya salto de numeración del consecutivo
			M->F1_DOC := LxChkNumNF(cSerie, M->F1_DOC, "SF1")

		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} LxSer2Col
	Valida campos para el país Colombia.
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasC: Alias tabla SF1/SF2.
			aCabNota: Campos del encabezado (SF1/SF2)
			cSerie: Serie del documento
			lSerie2: .T. Si utiliza serie 2.
	@return cSerie: Serie del documento fiscal.
	/*/
Function LxSer2Col(cAliasC, aCabNota, cSerie, lSerie2)
Local nPos := 0

Default cAliasC  := ""
Default aCabNota := {}
Default cSerie   := ""
Default lSerie2  := .F.

	If lSerie2
		nPos := Ascan(aCabNota[1], PrefixoCpo(cAliasC)+"_SERIE2")
		If nPos > 0 .And. Empty(cSerie)
			cSerie := aCabNota[2][nPos]
		EndIf
		If Empty(cSerie)
			nPos := Ascan(aCabNota[1],PrefixoCpo(cAliasC)+"_SERIE",++nPos)
			If ( nPos>0 )
				cSerie := aCabNota[2][nPos]
			EndIf
		EndIf
	Else
		nPos := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim(PrefixoCpo(cAliasC)+"_SERIE") } )
		IIf( nPos > 0, cSerie := aCabNota[2][nPos], "")
	EndIf

Return cSerie

/*/{Protheus.doc} NfTudOkCol
	Validaciones generales previo al grabado del documento fiscal.
	La función es ejecutada desde LOCXNF, función NfTudOk.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cAliasI: Alias de tabla SF1/SF2.
			cSerie: Serie del documento.
			aCfgNF: Array con la configuración del documento.
			aCitens: Items de NF (aCols).
			aCpItens: Campos de ítems (aHeader).
			cFilAnt: Filial del documento.
			cEspecie: Especie del documento fiscal.
			cnFiscal: Número de nota fiscal.
			cFunName: Nombre de la función del menú.
	@return lRet: .T. Si cumple con las condiciones.
	/*/
Function NfTudOkCol(cAliasI, cSerie, aCfgNF, aCitens, aCpItens, cFilAnt, cEspecie, cnFiscal, cFunName)
Local nI     := 0
Local lRet   := .T.
Local nSerie := 0
Local nNF    := 0
Local cAliasD:= ""
Local cMsg	 := ""
Local cProvFE  := SuperGetMV("MV_PROVFE",,"")
Local lAnexo19 := SuperGetMV("MV_ANEXO19",.F.,.F.)
Local nCodProd := 0

Default cAliasI  := ""
Default cSerie   := ""
Default aCfgNF   := {}
Default aCitens  := {}
Default aCpItens := {}
Default cFilAnt  := ""
Default cEspecie := ""
Default cnFiscal := ""

	If ( Len(cSerie) <= TamSX3(PrefixoCpo(cAliasI)+"_SERIE")[1])
		//³Verificando numeracao da NF em todos os itens
		nSerie	:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_SERIE"})
		nNF		:= Ascan(aCpItens, {|x| Trim(x) == PrefixoCpo(cAliasI)+"_DOC"})
		For nI := 1 to Len(aCitens)
			If !aCitens[nI][Len(aCitens[nI])] .AND. aCitens[nI][nNF] != cNFiscal .OR. aCitens[nI][nSerie] != cSerie
				Aviso(STR0005,STR0025+"("+cnFiscal+"-"+cSerie+"/"+aCitens[nI][nNF]+"-"+aCitens[nI][nSerie]+")",{STR0006})					    			 //"ATENCAO"###"Inconsistencias com a numeracao da NF em relacao a seus itens"###"OK"
				lRet := .F.
				Loop
			EndIf
		Next nI
	EndIf

	If lRet .and. Valtype(aCfgNF[SlFormProp]) == "L" .And. aCfgNF[SlFormProp] .And. (!Str(aCfgNF[SnTipo],2)$"54|64|50|60") .And. GetNewPar("MV_CTRLFOL",.F.)
		lRet := CtrFolios(cFilAnt, cSerie, cEspecie, cnFiscal)
	EndIf

	lRet := IIf(lRet .And. cFunName $ "MATA467N|MATA462N|MATA465N", LxVldCol(aCfgNf[SAliasHead]), lRet)

	If lRet .And. (cFunName $ "MATA101N|MATA466N" .Or. (lChkLxProp .and. ChkLxProp("ValidSerDocCol")))
		lRet := fSerDocCol()
	Endif

	cAliasD := IIf( aCfgNF[SAliasHead] == "SF1","F1","F2")

	If lRet .And. lAnexo19 .And. Alltrim(Str(aCfgNF[SnTipo],2))$"2|4" .And. !Empty(cProvFE) .And.  (aCfgNF[SAliasHead])->(ColumnPos(cAliasD+"_PTOEMIS")) > 0 .And. AllTrim(M->&(cAliasD+"_TIPOPE")) $"22|32" 
		If Empty(Replace(M->&(cAliasD+"_PTOEMIS"),"-"))
		cMsg := StrTran(STR0037 + AllTrim(M->&(cAliasD+"_TIPOPE")) ,"###", FWX3Titulo(cAliasD+"_TIPOPE") + "(" + cAliasD+"_TIPOPE" + ")") + ;//"Cuando el campo ### es igual a ", 
		        StrTran(STR0038,"###", FWX3Titulo(cAliasD+"_PTOEMIS")+"(" + cAliasD+"_PTOEMIS" + ")")        //", el valor del campo ### debe ser informado tomando en cuenta la nomenclatura MM-AAAA"
    	Aviso(STR0005,cMsg,{STR0006})	//Atencion //Ok
			lRet := .F.
		EndIf
	Endif

	If cAliasD == "F2" .and. cFunName $ "MATA467N".and. Alltrim(Str(aCfgNF[SnTipo],2)) == "1" .and. !Empty(cProvFE) .and. AllTrim(M->&(cAliasD+"_TIPOPE")) == "11"
		nCodProd:= Ascan(aCpItens, {|x| Trim(x) == "D2_COD"})
		lRet := aVldMdCol("SD2",aCitens,nCodProd)
	Endif

Return lRet

/*/{Protheus.doc} xTesAutCol
	Función para obtener TES y Código Fiscal por tipo de documento.
	La función es ejecutada desde LOCXNF2, función TESAutoCol.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cTabla: Alias de tabla: SC6, SC7, SD1 o SD2.
	@return .T..
	/*/
Function xTesAutCol(cTabla)
Local nPosCod		:= 0
Local nPosTes		:= 0
Local nPosCF		:= 0
Local cCod			:= ""
Local cTES			:= Space(TamSX3("D2_TES")[1])
Local cCF			:= Space(TamSX3("D2_CF")[1])
Local lAutTES		:= SuperGetMV("MV_AUTTES", .F., .T.) //Parametro que indica activacion de TES automatizada
Local cFilSB1		:= xFilial("SB1")
Local cFilSF4		:= xFilial("SF4")
Local cFilSA2		:= xFilial("SA2")
local cFilSA1		:= xFilial("SA1")
Local cOriCliPro	:= ""
Local lDocsSalida	:= IIf(FunName() $ 'MATA467N|MATA462N|MATA465N', .T., .F.)
Local cPrefTabla	:= IIf(lDocsSalida, "SA1", "SA2")
Local cCampoEst		:= IIf(lDocsSalida, "A1_EST", "A2_EST")
Local cFilCliPro	:= IIf(lDocsSalida, cFilSA1, cFilSA2)
Local lCpoCFO       := SC7->(ColumnPos("C7_CF")) > 0
Local lCpoCodmun    := SD1->(ColumnPos('D1_CODMUN')) > 0
Local lCpoTpActiv   := SD1->(ColumnPos('D1_TPACTIV')) > 0
Local lCpCodMD2    := SD2->(ColumnPos('D2_CODMUN')) > 0
Local lCpTpActD2   := SD2->(ColumnPos('D2_TPACTIV')) > 0
Local cTpActiv      := ""
Local cCodMun       := ""
Local nPosCodMun    := 0
Local nPosTpActiv   := 0
Local lMfisFound    := MafisFound() 

Default cTabla	  := ""

	Do Case
		Case cTabla == "SC6"//Pedidos de Venta
			If ReadVar() == "M->C6_PRODUTO"
				cCod := M->C6_PRODUTO
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
				cCod := aCols[n][nPosCod]
			EndIf
			nPosTes	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
			nPosCF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_CF"})
			If !lAutTES
				cOriCliPro := Posicione("SA1", 1, cFilSA1 + M->C5_CLIENTE + M->C5_LOJACLI, "A1_EST")
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					aCols[n][nPosTes] := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TS')
					aCols[n][nPosCF] := Posicione("SF4", 1, cFilSF4 + aCols[n][nPosTes], 'F4_CF')
				Else
					aCols[n][nPosTes] := cTES
					aCols[n][nPosCF] := cCF
				EndIf
			Else
				aCols[n][nPosTes] := LxTESAutoCOL(M->C5_CLIENTE, M->C5_LOJACLI, cCod, "TES", "")
				aCols[n][nPosCF]  := LxTESAutoCOL(M->C5_CLIENTE, M->C5_LOJACLI, cCod, "CF", "")
			EndIf
			
		Case cTabla == "SC7" //Pedidos de Compra
			If ReadVar() == "M->C7_PRODUTO"
				cCod := M->C7_PRODUTO
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
				cCod := aCols[n][nPosCod]
			EndIf
			If !lAutTES //Sin Automatizacion de TES
				cOriCliPro := Posicione("SA2", 1, cFilSA2 + cA120Forn + cA120loj, "A2_EST")
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TE')
					If lCpoCFO
						cCF:= Posicione("SF4", 1, cFilSF4 + cTES, 'F4_CF')
					Endif
				EndIf
			Else
				cTES := LxTESAutoCOL(cA120Forn, cA120loj, cCod, "TES", "")
			EndIf
			MaFisRef("IT_TES", "MT120", cTES)
			if lCpoCFO
				MaFisRef("IT_CF", "MT120", cCF)
			Endif

		Case cTabla == "SD1"
			If ReadVar() == "M->D1_COD"
				cCod := M->D1_COD
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
				cCod := aCols[n][nPosCod]
			EndIf
			If !lAutTES
				cOriCliPro := Posicione(cPrefTabla, 1, cFilCliPro + M->F1_FORNECE + M->F1_LOJA, cCampoEst)
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TE')
					cCF := Posicione("SF4", 1, cFilSF4 + cTES, 'F4_CF')
				EndIf
			Else
				cTES := LxTESAutoCOL(M->F1_FORNECE, M->F1_LOJA, cCod, "TES", "SD1")
				cCF := LxTESAutoCOL(M->F1_FORNECE, M->F1_LOJA, cCod, "CF", "SD1")
			EndIf
			If Type("aCols")<> "U" 
				If lCpoTpActiv
					cTpActiv := M->F1_TPACTIV
					nPosTpActiv	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TPACTIV"})
					if  nPosTpActiv > 0 .and. Empty(aCols[n][nPosTpActiv])
						aCols[n][nPosTpActiv] := cTpActiv
						If lMfisFound
							MaFisLoad("IT_TPACTIV",cTpActiv,n)
						Endif
					EndIf
				Endif
				If lCpoCodmun	
					cCodMun := M->F1_CODMUN
					nPosCodMun	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CODMUN"})
					if nPosCodMun > 0 .and. Empty(aCols[n][nPosCodMun])
						aCols[n][nPosCodMun] := cCodMun
						If lMfisFound
							MaFisLoad("IT_CODMUN",cCodMun,n)
						Endif
					Endif
				EndIf
			Endif
			If !Empty(cTES) .And. Type("n") == "N" .And. lMfisFound .and. !(cTES == MaFisRet(n,"IT_TES"))
				MaFisRef("IT_TES", "MT100", cTES)
			EndIf
			MaFisRef("IT_CF", "MT100", cCF)
		Case (cTabla == "SD2" .Or. cTabla == "D2")
			If ReadVar() == "M->D2_COD"
				cCod := M->D2_COD
			Else
				nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_COD"})
				cCod := aCols[n][nPosCod]
			EndIf
			If !lAutTES
				cOriCliPro := Posicione(cPrefTabla, 1, cFilCliPro + M->F2_CLIENTE + M->F2_LOJA, cCampoEst)
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TS')
					cCF := Posicione("SF4", 1, cFilSF4 + cTES, 'F4_CF')
				EndIf
			Else
				cTES := LxTESAutoCOL(M->F2_CLIENTE, M->F2_LOJA, cCod, "TES", "SD2")
				cCF := LxTESAutoCOL(M->F2_CLIENTE, M->F2_LOJA, cCod, "CF", "SD2")
			EndIf

			MaFisRef("IT_TES", "MT100", cTES)
			MaFisRef("IT_CF", "MT100", cCF)
			
			
			If Type("aCols")<> "U" 
				If lMfisFound
					MaFisLFToLivro(n,{},.F.)
				ENDIF
				If lCpTpActD2
					cTpActiv := M->F2_TPACTIV
					nPosTpActiv	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TPACTIV"})
					if  nPosTpActiv > 0 .and. Empty(aCols[n][nPosTpActiv])
						
						If lMfisFound
							MaFisLoad("IT_TPACTIV",cTpActiv,n)
						Endif
						aCols[n][nPosTpActiv] := cTpActiv
					EndIf
				Endif
				If lCpCodMD2	
					cCodMun := M->F2_CODMUN
					nPosCodMun	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CODMUN"})
					if nPosCodMun > 0 .and. Empty(aCols[n][nPosCodMun])
						
						If lMfisFound
							MaFisLoad("IT_CODMUN",cCodMun,n)
						Endif
						aCols[n][nPosCodMun] := cCodMun
					Endif
				EndIf
			
			Endif 
		
			

		Case cTabla == "SCK"	//Presupuesto de Venta
			cCod := IIf( ReadVar() == "M->CK_PRODUTO", M->CK_PRODUTO, TMP1->CK_PRODUTO)
			If !lAutTES
				cOriCliPro := Posicione("SA1", 1, cFilSA1 + M->CJ_CLIENTE + M->CJ_LOJA, "A1_EST")
				If AllTrim(cOriCliPro) <> "EX" //Si no es extranjero
					cTES := Posicione("SB1", 1, cFilSB1 + cCod, 'B1_TS')
					cCF := Posicione("SF4", 1, cFilSF4 + cTES, 'F4_CF')
				EndIf
			Else
				cTES := LxTESAutoCOL(M->CJ_CLIENTE, M->CJ_LOJA, cCod, "TES", "")
				TMP1->CK_TES := cTES // Necesario para usar TES en LxTESAutoCOL()
				cCF := LxTESAutoCOL(M->CJ_CLIENTE, M->CJ_LOJA, cCod, "CF", "")
			EndIf

			TMP1->CK_TES := cTES
			TMP1->CK_CF := cCF

	EndCase

Return .T.

/*/{Protheus.doc} xAutTesCOL
	Función para obtener TES o Código Fiscal por tipo de documento.
	La función es ejecutada desde LOCXNF2, función LxTESAutoCOL.
	@type  Function
	@author Arturo Samaniego
	@since 25/08/2022
	@param	cClieProve: Código cliente/proveedor.
			cTienda: Código loja cliente/proveedor.
			cProducto: Código de producto.
			cTipo: Tipo de dato a obtener (TES o CF).
			cMovimiento: Alias de tabla SD1 o SD2.
			aHeader: Array de campos.
			aCols: Items del documento.
	@return Si cTipo = 'TES', regresa cTES. Si cTipo = 'CF', regresa código fiscal.
	/*/
Function xAutTesCOL(cClieProve, cTienda, cProducto, cTipo, cMovimiento)
Local cOrigClien	:= ""
Local cOrigProve	:= ""
Local cRegiClien	:= ""
Local cRegiProve	:= ""
Local cFunName		:= FunName()

Local cFilSA1	:= ""
Local cFilSA2	:= ""
Local cFilAI0	:= ""
Local cFilSB1	:= xFilial("SB1")
Local cFilSF4	:= xFilial("SF4")

Local cTesItem	:= Space(TamSX3("D1_TES")[1])
Local cTES		:= Space(TamSX3("D2_TES")[1])
Local cCodFisc	:= Space(TamSX3("D2_CF")[1])

Local nPosDocOri	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI"})
Local nPosTES		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})

Default cClieProve	:= ""
Default cTienda		:= ""
Default cProducto	:= ""
Default cTipo		:= ""
Default cMovimiento	:= ""
Default aHeader     := {}
Default aCols       := {}

	/* Descripcion de Rutinas:
	 *
	 * MATA410	-> Pedido de Venta/Salida
	 * MATA415/MATA416	-> Presupuesto de Venta/Salida
	 * MATA467N	-> Factura de Venta/Salida
	 * MATA462N	-> Remision de Venta/Salida
	 * MATA465N	-> Nota de Debito/Credito Clientes (Ventas)
	 * MATA121	-> Pedido de Compra/Entrada
	 * MATA101N	-> Factura de Compra/Entrada
	 * MATA102N	-> Remision de Compra/Entrada
	 * MATA466N	-> Nota de Debito/Credito Proveedores (Compras)
	 *
	 */
	If cFunName $ 'MATA410|MATA415|MATA416' // Si se accede desde la rutina Pedido de Venta/Salida
		cFilSA1 := xFilial("SA1")
		If cTipo == "TES"
			cOrigClien	:= Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del cliente
			If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
				cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TS") //TES para venta a Clientes del Extranjero
			Else
				If cFunName == 'MATA410'
					cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
				Else // Prespuesto de venta
					cRegiClien := M->CJ_TIPOCLI
				EndIf
				If cRegiClien == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
				ElseIf cRegiClien == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Pedido de Venta/Salida
		EndIf
		If cTipo == "CF"
			cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
			If cRegiClien == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
			EndIf
			If Empty(cCodFisc) // CF no debe quedar en blanco
				If cFunName == "MATA410"
					nPosTES := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_TES"})
					If !Empty(aCols[n][nPosTes])
						cCodFisc := Posicione("SF4", 1, cFilSF4 + aCols[n][nPosTes], 'F4_CF')
					EndIf
				Else
					If !Empty(TMP1->CK_TES)
						cCodFisc := Posicione("SF4", 1, cFilSF4 + TMP1->CK_TES, 'F4_CF')
					EndIf
				EndIf
			EndIf
			Return PadR(cCodFisc,TamSX3("D2_CF")[1]) // Retorna CF de Pedido de Venta/Salida
		EndIf
	EndIf

	If cFunName == "MATA467N" // Si se accede desde la rutina Factura de Venta/Salida
		cFilSA1 := xFilial("SA1")
		If cTipo == "TES"
			cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
			If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
				cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda,"A1_TS") //TES para venta a Clientes del Extranjero
			Else
				cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
				If cRegiClien == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
				ElseIf cRegiClien == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Factura de Compra/Entrada
		EndIf
		If cTipo == "CF"
			cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
			If cRegiClien == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF de Factura de Compra/Entrada
		EndIf
	EndIf

	If cFunName == 'MATA462N' // Si se accede desde la rutina Remision de Venta/Salida
		cFilSA1 := xFilial("SA1")
		If cTipo == 'TES'
			cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
			If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
				cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda,"A1_TS") //TES para venta a Clientes del Extranjero
			Else
				cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
				If cRegiClien == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
				ElseIf cRegiClien == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES
		EndIf
		If cTipo == 'CF'
			cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
		    If cRegiClien == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF
		EndIf
	EndIf

	If cFunName == 'MATA465N' // Si se accede desde la rutina Nota de Debito/Credito Clientes (Ventas)
		cFilSA1 := xFilial("SA1")
		If cMovimiento == 'SD1' // Credito
			If cTipo == 'TES'
				cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
				cTesItem := Posicione("SF4", 1, cFilSF4 + SD1->D1_TES, "F4_TESDV")
				If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
					cFilAI0 := xFilial("AI0")
					cTES := Posicione("AI0", 1, cFilAI0 + cClieProve + cTienda,"AI0_TE") //TES para venta a Clientes del Extranjero
				ElseIf AllTrim(cTesItem) <> ""
					cTES := cTesItem
				Else
					If !Empty(aCols[N,nPosDocOri]) //Si existe un documento origen, deja la misma CF
						cTES := aCols[N,nPosTES]
					Else
						cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
						If cRegiClien == '1' // Si es Regimen Comun
							cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
						ElseIf cRegiClien == '2' // Si es Regimen Simplificado
							cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") //TES para Regimen Simplificado
						EndIf
					EndIf
				EndIf
				Return cTES
			EndIf
			If cTipo == 'CF'
				cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
				If cRegiClien == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
		If cMovimiento == 'SD2' // Debito
			If cTipo == 'TES'
				cOrigClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_EST") // Obtiene el Origen del Cliente
				If AllTrim(cOrigClien) == 'EX' // Si el cliente es Extranjero
					cTES := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda,"A1_TS") //TES para venta a Clientes del Extranjero
				Else
					cRegiClien := Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_TPESSOA") // Obtiene el Regimen del Cliente
					If cRegiClien == '1' // Si es Regimen Comun
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
					ElseIf cRegiClien == '2' // Si es Regimen Simplificado
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") //TES para Regimen Simplificado
					EndIf
				EndIf
				Return cTES
			EndIf
			If cTipo == 'CF'
				cRegiClien := IIF(Posicione("SA1", 1, cFilSA1 + cClieProve + cTienda, "A1_DECLAR") == "D", "D", "N") // Se valida el Regimen del Cliente
			    If cRegiClien == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
	EndIf

	If cFunName == "MATA121" // Si se accede desde la rutina Pedido de Compra/Entrada
		cFilSA2 := xFilial("SA2")
		If cTipo == "TES"
			cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
			If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
				cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TE") //TES para venta a Proveedores del Extranjero
			Else
				cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
				If cRegiProve == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
				ElseIf cRegiProve == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Pedido de Compra/Entrada
		EndIf
	EndIf

	If cFunName $ "MATA101N" .Or.  (lChkLxProp .and. ChkLxProp("TesAutomaticaNFE"))// Si se accede desde la rutina Factura de Compra/Entrada
		cFilSA2 := xFilial("SA2")
		If cTipo == "TES"
			cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
			If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
				cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TE") //TES para venta a Proveedores del Extranjero
			Else
				cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
				If cRegiProve == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
				ElseIf cRegiProve == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES de Factura de Compra/Entrada
		EndIf
		If cTipo == "CF"
			cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
			If cRegiProve == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF
		EndIf
	EndIf

	If cFunName $ 'MATA102N' .Or. (lChkLxProp .and. ChkLxProp("TesAutomaticaRemEnt"))// Si se accede a la rutina Remision de Compra/Entrada
		cFilSA2 := xFilial("SA2")
		If cTipo == 'TES'
			cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
			If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
				cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TE") //TES para venta a Proveedores del Extranjero
			Else
				cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
				If cRegiProve == '1' // Si es Regimen Comun
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
				ElseIf cRegiProve == '2' // Si es Regimen Simplificado
					cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
				EndIf
			EndIf
			Return cTES // Retorna TES
		EndIf
		If cTipo == 'CF'
			cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
			If cRegiProve == 'D' // Si es Declarante
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
			Else
				cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
			EndIf
			Return cCodFisc // Retorna CF
		EndIf
	EndIf

	If cFunName $ 'MATA466N' .Or. (lChkLxProp .and. ChkLxProp("TesAutomaticaNotaCompras"))// Si se accede desde la rutina Nota de Credito/Debito Proveedor (Compras)
		cFilSA2 := xFilial("SA2")
		If cMovimiento == 'SD1' // Debito
			If cTipo == 'TES'
				cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
				If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
					cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TE") //TES para venta a Proveedores del Extranjero
				Else
					cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
					If cRegiProve == '1' // Si es Regimen Comun
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE") // TES para Regimen Comun
					ElseIf cRegiProve == '2' // Si es Regimen Simplificado
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TE2") // TES para Regimen Simplificado
					EndIf
				EndIf
				Return cTES // Retorna TES
			EndIf
			If cTipo == 'CF'
				cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
				If cRegiProve == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO2") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
		If cMovimiento == 'SD2' // Credito
			If cTipo == 'TES'
				cOrigProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_EST") // Se obtiene el Origen del Proveedor
				If AllTrim(cOrigProve) == 'EX' // Si el Proveedor es Extranjero
					cTES := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda,"A2_TS") //TES para venta a Proveedores del Extranjero
				Else
					cRegiProve := Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_TPESSOA") // Se obtiene el Regimen del Proveedor
			 		If cRegiProve == '1' // Si es Regimen Comun
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS") // TES para Regimen Comun
					ElseIf cRegiProve == '2' // Si es Regimen Simplificado
						cTES := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_TS2") // TES para Regimen Simplificado
					EndIf
				EndIf
				Return cTES // Retorna TES de Nota de Credito de Proveedor
			EndIf
			If cTipo == 'CF'
				cRegiProve := IIF(Posicione("SA2", 1, cFilSA2 + cClieProve + cTienda, "A2_DECLAR") == "D", "D", "N") // Se valida el Regimen del Proveedor
				If cRegiProve == 'D' // Si es Declarante
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO3") //Codigo Fiscal para Declarantes
				Else
					cCodFisc := Posicione("SB1", 1, cFilSB1 + cProducto, "B1_CFO4") //Codigo Fiscal para No Declarantes
				EndIf
				Return cCodFisc // Retorna CF
			EndIf
		EndIf
	EndIf

Return

/*/{Protheus.doc} LxVldCFCol
	Conservar CF asignado por automatización de TES o definido por el usuario.
	La función es llamada en SCMToREM, SCMToREM2, SCMToNF2 y LxDocOri (LOCXNF.PRW)
	@type  Function
	@author Arturo Samaniego
	@since 21/09/2022
	@param 	aCols: Array de ítems de nota fiscal.
			cCFO: Código fiscal.
			nLenAcols: Tamaño de array aCols (Len(aCols))
			nCpoCFO: Posición del campo D1_CFO/D2_CFO en aCols.
	@return Nil
	/*/
Function LxVldCFCol(aCols, cCFO, nLenAcols, nCpoCFO)
Default aCols     := {}
Default cCFO      := ""
Default nLenAcols := Len(aCols)
Default nCpoCFO   := 0

	If nCpoCFO > 0 .And. !(cCFO == aCols[nLenAcols][nCpoCFO])
		MaFisAlt("IT_CF", cCFO, nLenAcols)
		aCols[nLenAcols][nCpoCFO] := cCFO
	EndIf
Return
/*/{Protheus.doc} LxObtTpCol
Funcion utilizada en la rutina LOCXNF, función Mata466n().
Asigna el tipo de documento para las notas de ajuste.
@type Function
@author Alfredo Medrano
@since 24/08/2022
@version 1.0
@param nFrmProp, Númerico, ByRef, Opción para el Formulario propio 1= Si y  2 = No
@param nTipoFac, Númerico, ByRef, Tipo de Factura. 3 = Nota de Ajuste Débito y 4 = Nota de Ajuste Crédito.
@return nTipoDoc, Númerico, 7 para Nota Ajuste Crédito y 9 para Nota Ajuste Débito
/*/
Function LxObtTpCol( nFrmProp,  nTipoFac)
	Local nTipoDoc := 0
	DEFAULT nFrmProp := 0
	DEFAULT nTipoFac := 0

	If nFrmProp == 1 .AND. nTipoFac == 3//³Nota Ajuste NDP³
		nTipoDoc := 23
	ElseIf nFrmProp == 1 .AND. nTipoFac == 4//³Nota Ajuste NCP³
		nTipoDoc := 22
	Endif
Return nTipoDoc

/*/{Protheus.doc} LxSer2DsNa
Función utilizada en la rutina LOCXNF2, función LxExSer2().
Asigna la serie 2 para Docto soporte y Notas de Ajuste NCP/NDP
@type Function
@author Alfredo Medrano
@since 24/08/2022
@version 1.0
@param cVarAct,  Carácter, ByRef, Nombre Campo en Memoria
@param nNotAjus, Númerico, ByRef, Tipo de Factura.23 = Nota de Ajuste Débito y 22 = Nota de Ajuste Crédito.
@return .T.
/*/
Function LxSer2DsNa(cVarAct,nNotAjus)

	Local cSerDcT := ""
	Local cCampoDoc := ""
	Local cFunNamDc := FunName()
	Default cVarAct := ""
	If Type("lDocSp") == "U"
		Private lDocSp := .F.
	EndIf

	If lDocSp .AND. ((cFunNamDc $ 'MATA101N') .Or. (lChkLxProp .and. ChkLxProp("Serie2DocSoporte"))) // documento soporte
		cSerDcT := M->F1_SERIE+'1'
		cCampoDoc := 'F1_SERIE2'
	ElseIf nNotAjus == 22 .AND. cFunNamDc $ 'MATA466N' //Nota de Ajuste
		cSerDcT :=  M->F2_SERIE+'8' //NCP
		cCampoDoc := 'F2_SERIE2'
	ElseIf nNotAjus == 23 .AND. ((cFunNamDc $ 'MATA466N') .Or. (lChkLxProp .and. ChkLxProp("Serie2NotaAjusteF1"))) //Nota de Ajuste
		cSerDcT :=  M->F1_SERIE+'9' //NDP
		cCampoDoc := 'F1_SERIE2'
	EndIf
	SFP->(DBSETORDER(5))//FP_FILIAL+FP_FILUSO+FP_SERIE+FP_ESPECIE
	If ALLTRIM(cVaract) $ "M->F1_DOC/M->F1_SERIE/M->F2_DOC/M->F2_SERIE"
		If SFP->(DBSEEK(XFILIAL("SFP")+CFILANT+cSerDcT))
			M->&cCampoDoc:= SFP->FP_SERIE2
		Else
			M->&cCampoDoc:= ''
		EndIf
	EndIf

Return .T.


/*/{Protheus.doc} lxEstrcCol
	Cargar la configuración de los documentos 22 y 23  (NCP y NDP de Ajuste)
	en el array aCfg.
	Se utilizan en la función MontaCfgNf() del fuente LOCXNF
	@type  Function
	@author Alfredo Medrano
	@since 26/08/2022
	@version version
	@param nTipo, Númerico, indica el tipo de documento (NCP y NDP de Ajuste).
	@param aAtualiza, Array, Contiene los permisos para realizar acciones en el Formulario.
	@param aLpC, Array, Asientos Estandar Encabezado.
	@param aLpI, Array, Asientos Estandar Item.
	@param aBotoes, Array, Botones de pantalla.
	@param aTeclas, Array,Funciones llamadas por atajos (Tecla ejemplo: F6)
	@param aPergs, Array, Preguntas.
	@param aPE, Array, Puntos de entrada.
	@param bF12, Bloque de código, Funciones llamadas por atajos (Tecla ejemplo: F12)
	@param aCposGD, Nil , Nil
	@param aPcoLanc, Array, Funciones PCO
	@return aEstrcCol, Array, Array con estructura del documento.
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxEstrcCol(nTipo,aAtualiza, aLpC,aLpI,aBotoes,aTeclas,aPergs, aPE,bF12,aCposGD,aPcoLanc)
Local aEstrcCol := {}

If nTipo == 22 // Nota Ajuste NCP
	aEstrcCol := {22,"SA2",.T.,"SF2","SD2","-","SE2",GetSESNew("NCP")	,"-","D",aAtualiza	,aLpC	,aLpI,aBotoes,aTeclas,AClone(aPergs)	,aClone(aPE),.F.,STR0028,STR0028 + ' - ' + STR0030 ,.F.,bF12,aCposGD,{.F.,.F.},"22", NIL, aPcoLanc} //"Nota de Crédito"//"Nota Ajuste"
ElseIf nTipo == 23 // Nota Ajuste NDP
	aEstrcCol := {23,"SA2",.T.,"SF1","SD1","+","SE2",GetSESNew("NDP")  	,"+","C",aAtualiza	,aLpC	,aLpI,aBotoes,aTeclas,AClone(aPergs)	,aClone(aPE),.F.,STR0029,STR0029 + ' - ' + STR0030 ,.F.,bF12,aCposGD,{.F.,.F.},"23", NIL, aPcoLanc}//"Nota de Débito"//"Nota Ajuste"
EndIf
Return aEstrcCol


/*/{Protheus.doc} lxModDocSp
	Actualiza el tipo de Operación para Docto Soporte y Nota Ajuste (NCP y NDP)
	Se utiliza en la funcíon GravaCabNF() del fuente LOCXNF.
	@type  Function
	@author user
	@since 31/08/2022
	@version version
	@param cAlsDc, Caracter, Contiene el Alias de la tabla.
	@param lDocSp, Lógico, indica si es un Docto. Soporte.
	@param nTipoDoc, Númerico, indica el tipo de documento (NCP y NDP de Ajuste).
	@return .T.
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxModDocSp(cAlsDc, lDocSp,nTipoDoc)
	Local cTpEst := ""

	If cAlsDc == 'SF1'
		If (SF1->(ColumnPos("F1_SOPORT")) > 0 .AND. lDocSp) .OR. (SF1->(ColumnPos("F1_MARK")) > 0 .AND. nTipoDoc == 23) // Documento Soporte //Nota ajuste NDP
			If lDocSp
				SF1->F1_SOPORT  := "S"
			ElseIf nTipoDoc == 23
				SF1->F1_MARK  := "S"
			Endif
			cTpEst := Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_EST")
			SF1->F1_TIPOPE := IIF(AllTrim(cTpEst) != "EX", "10","11") //Customization ID
		EndIf
	ElseIf cAlsDc == 'SF2'
		If SF2->(ColumnPos("F2_MARK")) > 0 .AND. nTipoDoc == 22
			SF2->F2_MARK  := "S"
			cTpEst := Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_EST")
			SF2->F2_TIPOPE := IIF(AllTrim(cTpEst) != "EX", "10","11") //Customization ID
		EndIf
	EndIf
Return .T.

/*/{Protheus.doc} lxVlDcTrns
	Para NCP de ajuste, cuando es seleccionada la opción "Doc Orig"
	valida que el Docto Soporte(SF1) seleccionado se encuentre transmitido.
	Se utiliza en la funcíon F4NfOri() del fuente SIGACUS
	@type  Function
	@author Alfredo Medrano
	@since 02/09/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxVlDcTrns(cDoc, cSerie, cFornece, cLoja)
	Local aArea := GetArea()
	Local lRet := .T.

	DbSelectArea('SF1')
	SF1->(DbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If SF1->(MSSEEK(xFilial("SF1") + cDoc + cSerie + cFornece +cLoja ))
		If (Empty(SF1->F1_FLFTEX) .Or. SF1->F1_FLFTEX == "0") .Or. Empty(SF1->F1_UUID)
			MsgAlert(StrTran(STR0031, '###', AllTrim(SF1->F1_SERIE) + " " +  AllTrim(SF1->F1_DOC))) //"El documento seleccionado (###), no ha sido transmitido. Realice la transmisión e intente nuevamente."
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return lRet
/*/{Protheus.doc} lxVlTitulo
	Obtiene el “Título” de Docto Soporte, Nota de Ajuste de Crédito o Débito
	que será mostrado en el encabezado del Formulario.
	Se utiliza en la funcíon LocxDlgNF() del fuente LOCXNF
	@type  Function
	@author Alfredo Medrano
	@since 05/09/2022
	@version version
	@param lDcSopr, Lógico, Indica si es un Documento Soporte.
	@param nTipDcS, Número, tipo de documento. 22 =NCP, 23= NDP
	@param cTxTCadas, Carácter, Contiene el título del Formulario.
	@return cTitForm, Carácter, Título del Formulario
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxVlTitulo(lDcSopr, nTipDcS, cTxTCadas )
Local cTitForm := ""
Default nTipDcS := 0
Default lDocSp:= .F.
Default cTxTCadas := ""
	cTitForm := cTxTCadas
	If lDcSopr
		 cTitForm := cTxTCadas +" - " + STR0027 // Documento Soporte
	ElseIf nTipDcS == 22
	 	 cTitForm := STR0028 +" - " + STR0030 //"Nota de Crédito" +" - Nota Ajuste"
	ElseIf nTipDcS == 23
		 cTitForm := STR0029 + " - " + STR0030 //"Nota de Débito" +" - Nota Ajuste"
	EndIf
Return cTitForm


/*/{Protheus.doc} lxObtnFltr
	Agrega Filtro para NCP y NDP de ajuste cuando es seleccionada
	la opción "Factura".
	Se utiliza en la función LxN466ForF6 del fuente Locxnf2
	Se utiliza en la funcíon F4NfOri() del fuente SIGACUS
	@type  Function
	@author user
	@since 05/09/2022
	@version version
	@param nTpDocS, Número, tipo de documento. 22 =NCP, 23= NDP
	@param lEsQry, Lógico, Indica si el filtro es una instrucción ADVPL o SQL
	@return cFiltro, Carácter, instrucción ADVPL o SQL
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxObtnFltr(nTpDocS, lEsQry)
	Local lCpsExs   :=  SF1->(ColumnPos("F1_SOPORT ")) > 0 .AND. SF1->(ColumnPos("F1_MARK")) > 0
	Local cQry		:= ""
	Local cCond		:= ""
	Local cFiltro   := ""
	Default lEsQry := .T.
	Default nTpDocS := 0

	If lCpsExs
		If nTpDocS == 22 .or. nTpDocS == 23 // Nota Ajuste 22 =NCP, 23= NDP
			cQry := "	AND SF1.F1_SOPORT = 'S'"
			cCond := "  .AND. F1_SOPORT == 'S'"
		Else
			cQry := "	AND SF1.F1_SOPORT <> 'S' AND SF1.F1_MARK <> 'S'"
			cCond := "  .AND. F1_SOPORT <> 'S' .AND. F1_MARK <> 'S'"
		EndIf
	EndIf
	cFiltro :=  IIf(lEsQry,cQry, cCond)


Return cFiltro


/*/{Protheus.doc} lxChckLock
	Para NCP y NDP de ajuste cuando es seleccionada la opción "Factura"
	valida que el Docto Soporte(SF1) seleccionado se encuentre transmitido.
	Se Utiliza en la funcion LockClick() del fuente LOCXGEN.
	@type  Function
	@author Alfredo Medrano
	@since 06/09/2022
	@version version
	@param cAlias, Carácter, Alias de la tabla.
	@param nReg, Número, Número de registro seleccionado
	@param aLinha, Array, Array con las lineas del grid
	@param oLbCli, Objeto, Objeto del grid
	@param cTipoFE, Carácter, Tipo de Validación Electronica  1 = Val. Previa
	@param nMarca, Número, indica si la casilla esta marcada > 0 o desmarcada = -1
	@return nMarca, Número,  Marcado > 0  Desmarcado = -1
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxChckLock(cAlias,nReg,aLinha,oLbCli,cTipoFE,nMarca)

If !Empty(SF1->F1_UUID) .And. (SF1->F1_FLFTEX == "1" .Or. (cTipoFE == "1" .And. SF1->F1_FLFTEX == "6"))
		If aLinha[oLBCli:nAT,1] == 1 //Retira Lock
			MsRUnlock(&(cAlias)->(nReg))
		Else
			If MsRLock(&(cAlias)->(nReg))
				nMarca := 1
			Else
				Help(" ", 1, "USUNAUTO")
			EndIf
		EndIf
	Else
		If aLinha[oLBCli:nAT,1] == 1 //Retira lock
			MsRUnlock(&(cAlias)->(nReg))
		EndIf
		MsgAlert(STR0026) //"El documento seleccionado no ha sido transmitido. Realice la transmisión e intente nuevamente."
	EndIf


Return nMarca
/*/{Protheus.doc} lxLocal
	Valida que en NCP y RCD no se utilice almacén de calidad
	@type  Function
	@author ARodriguez
	@since 06/10/2022
	@version 1.0
	@param cLocal, c, almacén
	@return lRet, l, almacén válido
/*/
Function lxLocal(cLocal)
	Local cCQ	:= SuperGetMV("MV_CQ",.F.,"98")
	Local lRet	:= .T.

	If cPaisLoc $ "COL|EQU|MEX|PER" .And. FunName() $ "MATA466N|MATA102DN" .And. cEspecie $ "NCP|RCD"
		If Alltrim(cLocal) == cCQ
			Aviso(STR0005,STR0035,{STR0006}) //"No se permite usar el código del almacén de calidad para este documento."
			lRet := .F.
		EndIf
	EndIf

Return lRet
/*/{Protheus.doc} lxDspVlCol
	Convierte el valor a moneda local.
	Se Utiliza en la funcion RetCusEnt() del fuente SIGACUSA.
	@type  Function
	@author Alfredo Medrano
	@since 04/10/2022
	@version version
	@param nValor, Número, Valor del Documento.
	@param nMoedaNF, Número, Moneda del Documento.
	@param nMedaDest,Número, Moneda de conversión.
	@param dData, Date, Fecha de Tasa de Moneda de conversión.
	@param aMoedDecs, Array, Array con tasa de la monedas.
	@param nTaxaOri, Número, Tasa de la moneda origen.
	@param nTaxaDest, Número, Tasa de la moneda destino.
	@return nValTot, Número, Valor convertido a la moneda local.
	@example
	(examples)
	@see (links_or_references)
	/*/
Function lxDspVlCol(nValor,nMoedaNF,nMedaDest,dData,aMoedDecs,nTaxaOri,nTaxaDest)
	Local nValTot := 0
	nValTot := xMoeda(nValor,nMoedaNF,nMedaDest,dData,If(aMoedDecs[nMedaDest]==0,MsDecimais(nMedaDest),aMoedDecs[nMedaDest]),nTaxaOri,nTaxaDest)
Return nValTot

/*/{Protheus.doc} LxVldPeri
	@type  Function
	@author Veronica Flores
	@since 22/01/2024
	@version version
	@param cAlias, caracter, Alias de la tabla.
	@return lRet, boolean, si es un formato de fecha 
	@example
	(examples)
	@see (links_or_references)
	/*/
Function LxVldPeri(cAlias)
	Local lRet			:= .T.
	Local aFecha 		:= {}
	Local cCampo 		:= "" 

	Default cAlias := ""

	If !Empty(cAlias)
		cCampo := IIF(cAlias == "SF1","F1_PTOEMIS","F2_PTOEMIS")

		If !Empty(REPLACE(M->&cCampo,"-"))
			aFecha := StrTokArr(M->&cCampo,"-")
			If VAL(aFecha[1]) < 1 .or. VAL(aFecha[1]) > 12 .or. Len(AllTrim(aFecha[2])) < 4 .or. VAL(aFecha[2]) < 1900
				lRet := .F.
			End If
		EndIf
		
		If !lRet 
			Aviso(STR0005, STR0036 , {STR0006}) //"Indicar un mes y/o año valido valido MM-YYYY"
		EndIf
	EndIf

Return lRet	


/*/{Protheus.doc} LocxAtuAcols
description Funcao utilizada para zerar aCols quando o proveedor do cabeçalho da fatura for diferente do proveedor na linha de itens 
@type function
@version 12.1.2210 
@author renan Silva #RES
@since 31/01/2024
@param aHeader, array, param_description
@param aCols, array, param_description
@return variant, return_description
/*/
Function LocxAtuAcols(aHeader,aCols)

Local cVarCont	:= Right(aCfgNF[5],2)+"_ITEM"   // aCfgNF[SAliasCols]
Local cItem		:= ""
Local nX		:= 0
Local lDel		:=.T.
Local nLin		:= 1


	//Zera aCols e executa refresh dos totalizadores
	aCols := {}
	MaFisClear()
	aAdd(aCols,Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == cVarCont
			cVarCont := aCfgNF[5]+"->"+cVarCont  // aCfgNf[SAliasCols]
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil .AND. !Empty(cItem),cItem,StrZero(1,Len(&cVarCont)))
		Else//If ( aHeader[nX][10] <> "V")   // existem campos vituais que devem aparecer na tela exp. Tipo de Operacao
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],.T.)
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	oGetDados:Refresh()
    // Limpa Tela de Qtd. Total dos Produtos
    lDel := Iif(Len(oBSomaItens:AARRAY)>0,.T.,.F.)
	While lDel
		nLin:= Len(oBSomaItens:AARRAY)
		If Len(oBSomaItens:AARRAY) == 1
			oBSomaItens:AARRAY[nLin,1] := ''
			oBSomaItens:AARRAY[nLin,2] := 0
			lDel:=.F.
		Else
			Adel(oBSomaItens:AARRAY,nLin)
			ASize(oBSomaItens:AARRAY,Len(oBSomaItens:AARRAY)-1)
		EndIf
	EndDo

	nTotQtIte:= 0
	oBSomaItens:Refresh()
	ModxAtuObj()

Return aCols

/*/{Protheus.doc} LocxShowHelp
Si es una rutina automática obliga a mostrar mensajes (Helps) en la pantalla siempre y cuando 
se encuentre configurado el parámetro MV_CT105MS = S.
Se utiliza en la funcion CtbilNF() de la rutina LOCXNF
@type function
@version 12.1.2210 
@author Alfredo Medrano
@since 29/02/2024
@param lSetAuto, booleano, indica el comportamiento del modo de ejecución.
@param lSetHelp, booleano, indica el comportamiento para mostrar los Helps en la pantalla.
@return lRehace, booleano, sí .F. indica si será habilitado la presentación del Help en pantalla, si .T. Regenera valores. 
/*/
Function LocxShowHelp(lSetAuto, lSetHelp, lRehace)
	Default lSetAuto := .T.
	Default lSetHelp := .T.
	Default lRehace	 := .T.

	If lRehace
		_SetAutoMode(lSetAuto)
		HelpInDark(lSetHelp)
	Else
		lSetAuto := _SetAutoMode(.F.) 
		lSetHelp := HelpInDark(.F.)
	EndIf

	If Type('lMSHelpAuto') == 'L'
		lMSHelpAuto := !lMSHelpAuto
	EndIf
return .T.

/*/{Protheus.doc} LxDocSpNCP()
	Valida consecutivo documento en Notas de Ajuste Crédito, de Documento Soporte
	@type  Function
	@author ARodriguez
	@since 19/07/2024
	@version 1
	@param cSerie, string, serie
	@param cNFiscal, string, serie -> por Referencia
	@return lRet, lógico, es válido?
	@example
	lRet := LxDocSpNCP(cSerie, @cNFiscal)
	@see (links_or_references)
	/*/
Function LxDocSpNCP(cSerie, cDoc)
	Local cFunName		:= IIf(Type("cFunName")=="U",Upper(Alltrim(FunName())),IIF(Empty(cFunName),Upper(Alltrim(FunName())),cFunName))
	Local lChkNumNF		:= FindFunction("LxChkNumNF")
	Local nUpdNum		:= SuperGetMV("MV_ALTNUM",,1)
	Local cAliasSF2		:= ""
	Local nReg			:= 0
	Local cNFiscal		:= ""
	Local lExist		:= .T.
	Local cNumAnt		:= ""
	Local lRet			:= .T.
	Local lSX5Comp		:= (FwModeAccess("SX5",3) == "C")	// Tabla SX5 compartida a nivel sucursal?
	Local cWhereFil		:= ""

	Default cSerie		:= ""
	Default cDoc		:= ""

	If aCfgNF[1] == 22 .And. (cFunName $ "MATA466N" .Or. (lChkLxProp .And. ChkLxProp("DocumentoSoporte"))) .And. !Empty(cDoc)
		// Validar que no se duplique NCP-Nota de ajuste
		cAliasSF2 := GetNextAlias()
		cWhereFil := IIf(lSX5Comp, "% 1=1 %", "% SF2.F2_FILIAL = '" + xFilial("SF2") + "' %" )

		BeginSQL Alias cAliasSF2
			%noparser%
			SELECT SF2.R_E_C_N_O_
			FROM %table:SF2% SF2
			WHERE %Exp:cWhereFil% AND
				SF2.F2_SERIE = %exp:cSerie% AND
				SF2.F2_DOC = %exp:cDoc% AND
				SF2.F2_TIPODOC = '22' AND
				SF2.%notDel%
		EndSQL

		Count to nReg
		(cAliasSF2)->(DBCloseArea())

		If nReg > 0
			If (nUpdNum == 1 .Or. nUpdNum == 2)
				// Ya existe el número de documento de la serie, buscar el folio más alto
				cNFiscal := cDoc

				BeginSql Alias cAliasSF2
					%noparser%
					SELECT MAX(F2_DOC) NUMDOC
					FROM %table:SF2% SF2
					WHERE %Exp:cWhereFil% AND
						SF2.F2_SERIE = %exp:cSerie% AND
						SF2.%notDel%
				EndSql

				If !(cAliasSF2)->(Eof())
					If !Empty((cAliasSF2)->NUMDOC)
						cNFiscal := (cAliasSF2)->NUMDOC
					EndIf
				EndIf

				(cAliasSF2)->(DBCloseArea())

				While lExist
					cNFiscal := Soma1(cNFiscal)
					lExist   := !aNumNaoExiste("SF2", cSerie, cNFiscal, M->F2_CLIENTE, M->F2_LOJA, M->F2_ESPECIE, "DCS")
				EndDo

				If nUpdNum == 1 //Realiza la actualización de la numeración.
					cNumAnt := cDoc
					cDoc := cNFiscal
					MsgInfo(STR0039 + cNumAnt + STR0040 + cNFiscal, STR0041) //El número del documento fue modificado de: #  a:  # Número

				ElseIf nUpdNum == 2 //Pregunta si debe realizar la actualización de la numeración.
					lRet := MsgYesNo(STR0042 + cDoc + STR0043 + cNFiscal) //El documento Nº:  #  existe, confirma modificación de la numeración a:
					If lRet
						cDoc := cNFiscal
					EndIf

				EndIf	//nUpdNum == 3 - No realiza la actualización de la numeración, envía mensaje

			EndIf

		ElseIf lChkNumNF
			// Valida que no haya salto de numeración del consecutivo
			cDoc := LxChkNumNF(cSerie, cDoc, "SF2")

		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} LxTraCOL()
	Realiza la transmisión electrónica de documentos fiscales para el país Colombia
	Validación, Generación del XML, Transmisión Electrónica y Actualización de Estatus.
	@type  Function
	@author Luis Enríquez
	@since 08/08/2024
	@version 2
	@param cAlias, string, Alias del documento (SF1/SF2)
	@param cEspDoc, string, Especie del documento
	@param cSerie, string, Serie del documento
	@param cFolio, string, Folio del documento
	@param cFolioFin, string, Folio del documento final(JOB)
	@param lJOB    , boolean, Determina si la ejecución es por JOB
	@return aLogJOB, array, Solo se retorna cuando la ejecución es por JOB, contiene el log del proceso
	@example
	LxTraCOL(cAlias,cEspDoc,cSerie,cFolio,cFolioFin,lJOB)
	@see (links_or_references)
	/*/
Function LxTraCOL(cAlias,cEspDoc,cSerie,cFolio,cFolioFin,lJOB)
	Local lProc := .T.
	Local aFact   := {}
	Local aError  := {}
	Local aTrans  := {}
	Local aNoEnv  := {}
	Local nTotDoc := 0
	Local cUrl    := GetNewPar("MV_WSRTSS","")
	Local cCFDUso := Alltrim(GetMv("MV_CFDUSO", .T., ""))
	Local nI      := 1
	Local cMsg    := ""
	Local cSerDoc := ""
	Local cCRLF   := (chr(13)+chr(10))
	Local lTran   := .F. //Transmisión Electrónica
	Local lEnvM   := .F. //Envío por E-mail
	Local nTamEsp := GetSX3Cache("F1_ESPECIE","X3_TAMANHO")
	Local nX      := 0
	Local cDesDoc := ""
	Local aArea	  := GetArea()
	Local lDocSop := .F.
	Local lCpoSoport := SF1->(ColumnPos("F1_SOPORT")) > 0
	Local aLogJOB := {}

	Private aDocAct  := {}
	Private nTipoDoc := IIf(cAlias == "SF2", 1,0) //1 - Salida 0 - Entradas
	Private nTDTras  := 0 //Factura, se debe asignar dependiendo la especie
	Private cEspecie := ""
	Private cTipDocto := ""
	Private _lCerRet	:= .F.

	Default cAlias  := ""
	Default cEspDoc := ""
	Default cSerie  := ""
	Default cFolio  := ""
	Default cFolioFin:= ""
	Default lJOB    := .F.
	
	if !lJOB
		cFolioFin := cFolio
	Endif

	cEspecie := cEspDoc

	If cEspDoc == "NF" 
		
		lDocSop := lCpoSoport .and. cAlias=="SF1" .and. Iif(!lJOB,SF1->F1_SOPORT == "S",lJOB)
		
		If ( lDocSop)  //6-Documento Soporte
			nTDTras  := 6
			cDesDoc := STR0027 + " " //"Documento Soporte"
		Else //1-Factura
			nTDTras  := 1
			cDesDoc := STR0044 + " " //"Factura de Venta"
		EndIf
		
	ElseIf cEspDoc == "NDC" //2-Nota de Débito
		nTDTras  := 2
		cDesDoc := STR0029 + " " //"Nota de Débito"
	ElseIf cEspDoc == "NCC" //3-Nota de Credito
		nTDTras  := 3
		cDesDoc := STR0028 + " " //"Nota de Crédito"
	ElseIf cEspDoc == "NDP" .And. (lJOB .Or. (SF1->(ColumnPos("F1_MARK")) > 0 .And. SF1->F1_MARK == "S")) //8-Nota de Ajuste - Débito
		nTDTras  := 8
		cDesDoc := STR0030 + " " + STR0046//"Nota de Ajuste" "de Débito"
	ElseIf cEspDoc == "NCP" .And. (lJOB .Or. (SF2->(ColumnPos("F2_MARK")) > 0 .And. SF2->F2_MARK == "S")) //9-Nota de Ajuste - Crédito
		nTDTras  := 9
		cDesDoc := STR0030 + " " + STR0045//"Nota de Ajuste" //"de Crédito"
	EndIf

	If nTDTras == 1 .Or. nTDTras == 2 .Or. nTDTras == 3 .Or. nTDTras == 6 .Or. nTDTras == 8 .Or. nTDTras == 9
		//MV_CFDUSO = No existe o vacío no hace nada
		//MV_CFDUSO = 1 Pregunta transmitir y pregunta enviar por mail
		//MV_CFDUSO = 2 Pregunta transmitir y enviar por mail en automatico
		//MV_CFDUSO = 3 Transmite en automático y enviar por mail en automatico

		If cCFDUso $ "1|2" .and. !lJOB
			lTran := MsgYesNo(STR0047) //"Documento guardado, ¿Confirma la Transmisión Electrónica?"
			If lTran
				lEnvM := IIf(cCFDUso=="2",.T.,MsgYesNo(STR0048)) //"¿Confirma el envío por email del documento electrónico?"
			EndIf
		ElseIf cCFDUso == "3" .Or. lJOB
			lTran := .T.
			lEnvM := .T.
		EndIf

		If (cCFDUso $ "1|2|3" .or. lJOB) .And. lTran .And. FindFunction("M486VLDDOC") .And. FindFunction("M486GERXML") .And. FindFunction("M486SENDPT") .And. FindFunction("M486UPDST")
			cSerDoc := Alltrim(cSerie) + IIf(!Empty(cSerie),"-","") + Alltrim(cFolio)
			Processa({|lEnd| lProc := M486VLDDOC(cFolio,cFolioFin,cSerie,@aFact,@aError,@nTotDoc,.F.,lJOB)},STR0049 + cDesDoc + " " + cSerDoc + " ...") //"Validando "
			//Generación del XML
			If lProc
				If nTDTras == 6 //Documento Soporte
					cEspecie := Padr("NCC", nTamEsp) //Para tratamiento sobre SF1
				EndIf
				Processa({|lEnd| lProc := M486GERXML(aFact,@aError)} ,STR0050 + cDesDoc + " " + cSerDoc + "...") //"Generando XML de "
				//Transmisión del documento
				If lProc
					Processa({|lEnd| lProc := M486SENDPT(aFact,@aError,cUrl,@aTrans,@aNoEnv,.T.,lEnvM)},STR0051 + cDesDoc + " " + cSerDoc + " ...") //"Transmitiendo "
				EndIf
				//Actualización del estatus
				If lProc
					Processa({|lEnd| lProc := M486UPDST(IIf(Len(aDocAct)>0,aDocAct,aTrans))},STR0052 + cDesDoc + " " + cSerDoc + " ..." ) //"Actualizando "
					If lJOB .and. Len(aDocAct) > 0 .and. Len(aTrans) > 0
						M486UPDST(aTrans)
					Endif
				EndIf
				If lProc .and. !lJOB
					If Len(aError) <> Len(aTrans)
						For nX:=1 To Len(aError)
							cMsg += aError[nX][5] + cCRLF
						Next nX
						If !Empty(cMsg)
							cMsg += cCRLF + STR0060 //"Borrar el documento y volver a incluirlo, o relizar los ajustes necesarios y transmitir desde la rutina de Documentos Electrónicos (MATA486)."
							DEFINE MSDIALOG oDlg FROM 0,0 TO 390,440 PIXEL TITLE STR0005 //"Atención"
							oDlg:lMaximized := .F.
							oSay := TSay():New(05,05,{||OemToAnsi(STR0053)},oDlg,,,,,,.T.) //"Ocurrieron inconvenientes al momento de la transmisión electrónica:"
							oMemo:= tMultiget():New(20,05,{|u|IIf(Pcount() > 0, cMsg:=u, cMsg)} ,oDlg,213,155,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
							oButton := TButton():New(177, 187,STR0054,oDlg,{||oDlg:End()},30,15,,,,.T.) //"Salir"
							ACTIVATE MSDIALOG oDlg CENTERED
						EndIf
					Else
						cMsg := cDesDoc + " " + cSerDoc + " " + IIf(aTrans[1][7]=="6",IIf(nTDTras==6,STR0055,STR0056),IIf(aTrans[1][7]=="4",STR0057,"")) + "." //"Autorizado" //"Autorizada" //"está en Espera de Procesamiento"
						If Len(aNoEnv) > 0
							If nTDTras == 6 .Or. nTDTras == 8 .Or. nTDTras == 9
								cMsg += cCRLF + STR0061 //"No se realizó envío por Email, el parámetro MV_EMAILRE está vacío."
							Else
								cMsg += cCRLF + StrTran(STR0058,"###",FWX3Titulo("A1_EMAIL")) //"No se realizó envío por Email, el campo ### (A1_EMAIL) del Cliente está vacío"
							EndIf
						EndIf					
						Aviso(OemToAnsi(STR0034),cMsg,{OemToAnsi(STR0006)}) //"Transmisión Electrónica" //"OK"
					EndIf
				EndIf
			Else
				if !lJOB
					For nI:=1 to Len(aError)
						cMsg += aError[nI][5] + cCRLF
					Next nI
					If !Empty(cMsg)
						cMsg += cCRLF + STR0060 //"Borrar el documento y volver a incluirlo, o relizar los ajustes necesarios y transmitir desde la rutina de Documentos Electrónicos (MATA486)."
						DEFINE MSDIALOG oDlg FROM 0,0 TO 390,440 PIXEL TITLE STR0005 //"Atención"
						oDlg:lMaximized := .F.
						oSay := TSay():New(05,05,{||OemToAnsi(STR0059)},oDlg,,,,,,.T.) //"Se detectaron los siguientes detalles:"
						oMemo:= tMultiget():New(20,05,{|u|IIf(Pcount() > 0, cMsg:=u, cMsg)} ,oDlg,213,155,,.T.,,,,.T.,,,,,,.T.,,,,,.T.)
						oButton := TButton():New(177, 187,STR0054,oDlg,{||oDlg:End()},30,15,,,,.T.) //"Salir"
						ACTIVATE MSDIALOG oDlg CENTERED
					EndIf
				Endif
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
	if lJOB
		aLogJOB := M486GENLOG(aError,nTotDoc,len(aTrans),aNoEnv,.F.,lJOB)
		Return aLogJOB
	Endif
Return Nil

/*/{Protheus.doc} aVldMdCol
	Función para validación de Items de pedido de venta o factura de venta
	con tipo operación igual a 11 - Mandato
	@type  Function
	@author eduardo.manriquez
	@since 18/10/2024
	@version 1.0
	@param cTabla, caracter, Tabla items pedido de venta(SC6) o factura de venta(SD2) para realizar la validación 
		   aItems,    array, Arreglo con la información de los items de la factura 
		   nCodProd,caracter, Posición en el arreglo del campo D2_COD 	@return lRet , boolean , variable lógica que retorna .T. si el producto pasa las validaciones
	@example
	aVldMdCol(cTabla, cProd)
	@see
	/*/
Function aVldMdCol(cTabla,aItems,nCodProd)
	Local lCpoCodMan := SB1->(ColumnPos("B1_CODMAN")) > 0 
	Local nTamCodProd:= FWSX3Util():GetFieldStruct("B1_COD")[3]
	Local cProducto  := ""
	Local cCodItem   := ""
	Local cCRLF   := (Chr(13) + Chr(10))
	Local cFilSB1 := xFilial("SB1")
	Local nPosProd := 0
	Local aProductos := {}
	Local lRet       := .T.
	Local cMsjProd   := ""
	Local cMsj       := ""
	Local nI         := 0
	Local nPosDel    := 0

	Default cTabla   := ""
	Default aItems   := {}
	Default nCodProd := 0

	If lCpoCodMan	
		if Len(aItems) > 0
			SB1->( DBSetOrder( 1 ) )
			DbSelectArea("SB1")
			For nI := 1 to Len(aItems)
				cCodItem := Padr(aItems[nI][nCodProd],nTamCodProd," ")
				nPosDel  := Len(aItems[nI])
				cProducto:=cFilSB1 +cCodItem
				nPosProd := aScan(aProductos,{|x| x == cCodItem})
				If nPosProd == 0 .and. !aItems[nI][nPosDel]
					AADD(aProductos,cCodItem)
					If SB1->( MsSeek(cProducto) )
						if Empty(SB1->B1_CODMAN)				
							cMsjProd += cCodItem + cCRLF 
						Endif
					Endif
				Endif
			Next nI
			SB1->(DBCloseArea())
		Endif

		if  !Empty(cMsjProd)
			If (cTabla == "SC6")
				cMsj := STR0062+cCRLF+STR0065+cCRLF+cCRLF+cMsjProd+cCRLF+STR0066 // "Se informo Tipo Operación 11 - Mandato(C5_TIPOPE)" - "Los siguientes productos no cuentan con código de mandatorio(B1_CODMAN) informado y se reportarán como ingresos propios(IdEsquema igual a 0) al transmitir XML:"
			Else
				cMsj := STR0064+cCRLF+STR0065+cCRLF+cCRLF+cMsjProd+cCRLF+STR0066 // "Se informó Tipo Operación 11-Mandato(F2_TIPOPE)" - "Los siguientes productos no cuentan con código de mandatorio(B1_CODMAN) informado y se reportarán como ingresos propios(IdEsquema igual a 0) al transmitir XML:"
			Endif
			lRet := MsgYesNo(cMsj)
		Endif
	Endif

Return lRet



/*/{Protheus.doc} a410TudOkCol
	Función para validación en la grabación de pedido de venta para
	Colombia
	@type  Function
	@author eduardo.manriquez
	@since 18/10/2024
	@version 1.0
	@param 
	@return lRet , boolean , variable lógica que retorna .T. si se pasaron todas las validaciones
	@example
	a410TudOkCol()
	@see
	/*/
Function a410TudOkCol()
	Local lRet := .T.
	Local nPProduto  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
	Local cProvFE    := SuperGetMV("MV_PROVFE",,"")

	
	If !Empty(cProvFE) .and. SC5->(ColumnPos("C5_TIPOPE")) > 0 .and. M->C5_TIPOPE == "11"
		lRet := aVldMdCol("SC6",aCols,nPProduto)
	Endif

Return lRet

/*/{Protheus.doc} RatVICol
	Ajusta valores decimales cuando se presentan difencias entre el valor total de un impuesto vs la suma del impuesto por ítems.
	@type  Function
	@author luis.samaniego
	@since 05/04/2025
	@version 12.1.2410
	@param 
		aInfo, Array, Información de impuesto. [1]-Impuesto; [2]-Campo libro.
		nItem, Numeric, Numero ítem del documento.
		nAliq, Numeric, Alícuota del impuesto.
		nBase, Numeric, Valor de la base imponible del ítem.
		nMoneda, Numeric, Moneda del documento.
		nDivAlq, Numeric, Valor para dividir la alícuota de cálculo.
	@return nAuxVlr, Numeric, Valor del impuesto con el ajuste de decimales.
	/*/
Function RatVICol(aInfo, nItem, nAliq, nBase, nMoneda, nDivAlq)
Local nAuxVlr   := 0
Local nBaseT    := 0
Local nDecimais := 0
Local nValDif   := 0
Local nValDif1  := 0
Local nValorT   := 0
Local nVlrRat   := 0

Default aInfo := {}
Default nItem := 0
Default nAliq := 0
Default nBase := 0
Default nMoneda := 1
Default nDivAlq := 100

	If nItem > 0 .And. Len(aInfo) > 0 .And. MaFisFound()
		nDecimais := MsDecimais(nMoneda) //Decimales para la moneda seleccionada.
		nBaseT    := MaRetBasT(aInfo[2], nItem, nAliq) //Base total de impuesto

		nVlrRat := Round(nBaseT * (nAliq / nDivAlq), nDecimais) //Valor total de impuesto
		nAuxVlr := Round(nBase * (nAliq / nDivAlq), nDecimais) //Valor impuesto de item.
		nValorT := fSumValImp(aInfo, nItem, nAliq) + nAuxVlr //Suma el impuesto ya cálculado + impuesto del item

		/*En caso de presentar diferencias por redondeo, se realiza el ajuste de los valores decimales*/
		If nValorT <> nVlrRat
			nValDif := (nVlrRat - nValorT)
			nValDif1 := nValDif
			If nValDif < 0
				nValDif1 := (nValDif * -1)
			EndIf
			nCent := 1/(10 ** nDecimais)
			If nValDif1 >= nCent
				If nValDif > 0
					nAuxVlr += nValDif1
				Else
					nAuxVlr -= nValDif1
				EndIf
			EndIf
		EndIf
	EndIf

Return nAuxVlr


/*/{Protheus.doc} fSumValImp
	Obtiene la suma del impuesto en los ítems del documento fiscal.
	@type  Function
	@author luis.samaniego
	@since 05/04/2025
	@version 12.1.2410
	@param
		aInfo, Array, Información de impuesto. [1]-Impuesto; [2]-Campo libro.
		nItem, Numeric, Numero ítem del documento.
		nAliq, Numeric, Alícuota del impuesto.
	@return nAuxVlr, Numeric, Total impuesto.
	/*/
Function fSumValImp(aInfo, nItem, nAliq)
Local nAuxVlr := 0
Local nItemNF := 0
Local cNumImp := ""
Local cFunName := FunName()

Default aInfo := {}
Default nItem := 0
Default nAliq := 0

	If Type("aCols") == "U"
		aCols := {}
	EndIf

	If nItem > 0 .And. Len(aInfo) > 0
		cNumImp := aInfo[2] //Campo libro fiscal
		For nItemNF := 1 To Len(aCols)
			If MaFisFound("IT", nItemNF) .And. !MaFisRet(nItemNF, 'IT_DELETED') .And. ((cFunName $ "MATA410" .And.  nItemNF < nItem) .Or. (!(cFunName $ "MATA410") .And. nItemNF <> nItem))
				If MaFisRet(nItemNF,'IT_ALIQIV'+cNumImp) == nAliq
					nAuxVlr += MaFisRet(nItemNF,'IT_VALIV'+cNumImp)
				Endif
			EndIf
		Next
	EndIf

Return nAuxVlr
