#INCLUDE "FISA842.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "fwlibversion.ch"

#DEFINE _SEPARADOR ";"


#DEFINE _POSPUBLI   1
#DEFINE _POSDATINI 2
#DEFINE _POSDATFIN 3
#DEFINE _POSCGC    4
#DEFINE _POSTIPIN  5
#DEFINE _POSTIPO2  6
#DEFINE _POSCAMBIA  8
#DEFINE _POSALQPER 9
#DEFINE _POSALQRET 10
#DEFINE _POSGRPP  11
#DEFINE _POSGRPR  12
#DEFINE _POSNOME  13

#DEFINE _BUFFER 16384

Static oQryExec := Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA842  ³ Autor ³ luis Gerardo Mata    ³ Data ³ 15.08.2024 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Procesos a partir de un archivo TXT generado por la AFIP   ³±±
±±³           ³ actualización de alicuotas de percepción/retención  ER     ³±±
±±³           ³ SFH (ingresos brutos).                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³  Fiscal - Entre Rios - Argentina                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³  BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±

±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FISA842()

	Local cCombo	:= ""
	Local aCombo	:= {}
	Local oDlg		:= Nil
	Local oFld		:= Nil
	Local oCombo	:= Nil
	Local oChk1		:= Nil



	Private aQry := {}
	Private cMes := StrZero(Month(dDataBase),2) // Variable privada que almacena el mes del periodo digitalizado por el usuario.
	Private cAno := StrZero(Year(dDataBase),4) // Variable privada que almacena el año del periodo digitalizado por el usuario.
	Private oChk2 as object
	Private lRet  := .T. 
	Private lPer  := .T. 


	aAdd( aCombo, STR0002 ) //"1- Proveedor"
	aAdd( aCombo, STR0003 ) //"2- Cliente"
	aAdd( aCombo, STR0004 ) //"3- Ambos"


	DEFINE MSDIALOG oDlg TITLE STR0005 FROM 0,0 TO 250,450 OF oDlg PIXEL //"Resolución 208/24 para IIBB – Entre Ríos "

	@ 006,006 TO 040,170 LABEL STR0006 OF oDlg PIXEL //"Info. Preliminar"

	@ 011,010 SAY STR0007 SIZE 065,008 PIXEL OF oFld //"Archivo:"
	@ 020,010 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oFld ON CHANGE ValChk(cCombo)

	//+----------------------
	//| Campos Check-Up
	//+----------------------
	@ 10,115 SAY STR0008 SIZE 065,008 PIXEL OF oFld //"Imposto: "

	@ 020,115 CHECKBOX oChk1 VAR lPer PROMPT STR0009 SIZE 40,8 PIXEL OF oFld ON CHANGE ValChk(cCombo)  //"Percepción"
	@ 030,115 CHECKBOX oChk2 VAR lRet PROMPT STR0010 SIZE 40,8 PIXEL OF oFld ON CHANGE ValChk(cCombo) //"Retención"

	@ 041,006 FOLDER oFld OF oDlg PROMPT STR0011 PIXEL SIZE 165,075 //"&Importación de Archivo TXT"

	//+----------------
	//| Campos Folder 2
	//+----------------
	@ 005,005 SAY STR0012 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Esta opción tiene como objetivo actualizar el archivo    "
	@ 015,005 SAY STR0013 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Proveedor / Cliente vs. Impuesto de acuerdo con el archivo TXT  "
	@ 025,005 SAY STR0014 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"puesto a disposición por el gobierno   "                       "
	@ 045,005 SAY STR0015 SIZE 150,008 PIXEL OF oFld:aDialogs[1] //"Informe el periodo:"
	@ 045,055 MSGET cMes PICTURE "@E 99" VALID !Empty(cMes) SIZE  015,008 PIXEL OF oFld:aDialogs[1]	                                          
	@ 045,070 SAY "/" SIZE  150, 8 PIXEL OF oFld:aDialogs[1]
	@ 045,075 MSGET cAno PICTURE "@E 9999" VALID !Empty(cMes) SIZE 020,008 PIXEL OF oFld:aDialogs[1]

	//+-------------------
	//| Boton de MSDialog
	//+-------------------
	@ 055,178 BUTTON STR0016 SIZE 036,016 PIXEL ACTION ImpoArq(aCombo,cCombo) //"&Importar"
	@ 075,178 BUTTON STR0018 SIZE 036,016 PIXEL ACTION oDlg:End() //"&Salir"

	ACTIVATE MSDIALOG oDlg CENTER

Return Nil


/*/{Protheus.doc} ValChk
Programa que impide el uso del cheque de retención para clientes. 
@type  function
@version  1.0
@author luis.mata
@since 8/28/2024
@param cCombo, character, Variable con el valor elegido en el combo. 
@return lRet, logical,Variable que indica si puede continuar con el proceso de forma normal.
/*/
Static function ValChk(cCombo)
	Default cCombo := ""
		
	If lRet == .T. .and. Subs(cCombo,1,1) $ "2"    // El cliente no tiene retención
		lRet :=.F.
	EndIf	
	oChk2:Refresh()

Return lRet

/*/{Protheus.doc} ImpoArq
Inicializa la importación de archivos. 
@type function
@version  1.0
@author luis.mata
@since 8/28/2024
@param aCombo, array, Variable con las opciones del combo cli/pro   
@param cCombo, character, Variable con la opción elegida del combo.  
@param lVal, booleano, auxiliar para validar por automatizado cuando es fecha 
diferente del periodo o periodo vacio.
@return variant, no retorna valor
/*/
Static Function ImpoArq(aCombo,cCombo,lVal)

	Local   nPos     	:= 0
	Local   cLine    	:= ""
	Local	cfinal	 	:= ""
	Local	cPesq	 	:= "\"
	Local	nTamArq	 	:= 0
	Local	cValida  	:= ""
	Local   cFchIni   	:= ""
	Local   cFchFin   	:= ""
	Local  	cStartPath 	:= GetSrvProfString("StartPath","")
	Local  	cFile      	:= ""
	Local	dDataIni 	:= ""
	Local 	dDataFim 	:= ""	
	Local 	lFor     	:= .F.
	Local 	lCli     	:= .F.
	Local 	lImp     	:= .F.
	Local   Naux		:= 0
	Local   lCopy		:=.F.
	Local   oFile		:= Nil
	Private lAutomato := isblind()

    Default cCombo 		:= ""
    Default aCombo 		:= {}
	Default lVal	:=.F.




	nPos := aScan(aCombo,{|x| AllTrim(x) == AllTrim(cCombo)})
	If nPos == 1 // Proveedor
		lFor := .T.
	ElseIf nPos == 2 // Cliente
		lCli := .T.
	ElseIf nPos == 3 // Ambos
		lFor := .T.
		lCli := .T.
	EndIf
	

	
	// Seleciona el archivo
	IF !lAutomato
		cFile := FGetFil()
		If Empty(cFile)
			MsgStop(STR0047) //"Seleccione un archivo e intente nuevamente."
			Return Nil
		EndIf
	else
		cFile:=cFileAut
	EndIf

		If !lAutomato
			// Seleciona el archivo
			cStartPath := StrTran(cStartPath,"/","\")
			cStartPath +=If(Right(cStartPath,1)=="\","","\")
			cfinal:= cFile
			If !Empty(cFile) 	
				IF CpyT2S(cFile,cStartPath,.T.)
					lCopy:=.T.
				EndIf
			EndIF
		Endif
		If !File(cFile)
			Return Nil
		EndIf
		If !lAutomato		
			If !Substr(cFile,1,6) $ cStartPath
				While AT( cPesq, cfinal) > 0  		
					Naux:=AT( cPesq, cfinal ) 
					Naux:=Naux+1
					nTamArq:= Len(cfinal)
					cfinal:= SubStr(cfinal,Naux,nTamArq)		
				EndDo
			Endif
		Endif
		
		IF lAutomato
			oFile	:= FwFileReader():New(cFile)
		Else 
			oFile	:= FwFileReader():New(cStartPath + cfinal)
		EndIf 

		If (oFile:Open())
			If oFile:HasLine()
				cValida := oFile:GetLine()
			EndIf
		EndIf
		oFile:close()
		FreeObj(oFile)

			cFchIni := SubStr(cValida,14,4) + SubStr(cValida,12,2) + SubStr(cValida,10,2)
			dDataIni := STOD(cFchIni)
			cFchFin := SubStr(cValida,23,4) + SubStr(cValida,21,2) + SubStr(cValida,19,2)
			dDataFim := STOD(cFchFin) 
		If !lAutomato	.or. lVal		    
			If Trim(SubStr(DTOS(dDataIni),1,6)) == ""  
				lImp := .F.
				fDelFile(lCopy,cStartPath+cfinal,lVal)
				Return Nil	                                               
			ElseIf (cAno+cMes) <> SubStr(DTOS(dDataIni),1,6)
				MsgStop(STR0026+(SubStr(cLine,3,2)+"/"+SubStr(cLine,5,4))+")",STR0027) //" Periodo Informado no corresponde al periodo del archivo. (""###"Periodo"
				lImp := .F.
				fDelFile(lCopy,cStartPath+cfinal,lVal)
				Return Nil	 
			EndIf
			MsAguarde({|| ImpFWBSql(cFile,cStartPath,cfinal,cCombo)} ,STR0024,STR0025 ,.T.) //"Leyendo Archivo, Espere..."###"Actualización de alícuotas"
			lImp := .T.
		Else
			MsAguarde({|| ImpFWBSql(cFile,"","",cCombo)} ,STR0024,STR0025 ,.T.) //"Leyendo Archivo, Espere..."###"Actualización de alícuotas"
			lImp := .T.
		Endif
		If lImp
			MsAguarde({|| GerSFH(cFile,lRet,lPer,lCli,lFor,dDataIni,dDataFim)}   ,STR0039,STR0040,.T.) //"Verificación clientes/proveedores. Espere..."###"Creación de registros"				
			MsAguarde({|| FlSFHSql(lRet,lPer,lCli,lFor,dDataIni,dDataFim)} ,STR0024,STR0025 ,.T.) //"Leyendo Archivo, Espere..."###"Actualización de alícuotas"
			TCDelFile("PADRONARER")			
			aSize(aQry,0)
		EndIf	

	
	IF !lAutomato
		MsgAlert(STR0041,"") //"Archivo importado"
	ENDIF
	aSize(aQry,0)
	fDelFile(lCopy,cStartPath+cfinal)
	
Return Nil


/*/{Protheus.doc} FGetFil
Pantalla de selección del fichero txt a importar. 
@type function
@version  1.0
@author luis.mata
@since 8/28/2024
@return cRet, Directorio del archivo seleccionado..
/*/
Static Function FGetFil()
	Local oDlg01		:= Nil
	Local oGet01		:= Nil
	Local oBtn01		:= Nil
	Local oBtn02		:= Nil
	Local oBtn03		:= Nil

	Local cRet := Space(50)

	oDlg01 := MSDialog():New(000,000,100,500,STR0043,,,,,,,,,.T.)//"Seleccione Archivo"

	oGet01 := TGet():New(010,010,{|u| If(PCount()>0,cRet:=u,cRet)},oDlg01,215,10,,,,,,,,.T.,,,,,,,,,,"cRet")
	oBtn01 := TBtnBmp2():New(017,458,025,028,"folder6","folder6",,,{|| FGetDirt(oGet01)},oDlg01,STR0043,,.T.)//"Seleccione Archivo"

	oBtn02 := SButton():New(035,185,1,{|| oDlg01:End() }         ,oDlg01,.T.,,)
	oBtn03 := SButton():New(035,215,2,{|| cRet:="",oDlg01:End() },oDlg01,.T.,,)

	oDlg01:Activate(,,,.T.,,,)

Return cRet


/*/{Protheus.doc} FGetDirt
Pantalla para buscar y seleccionar el archivo en los directorios locais/servidor/unidades mapeadas.
@type function
@version  1.0
@author luis.mata
@since 8/28/2024
@param oTGet, object, Objeto TGet que recibirá la ubicación y el archivo selecionado. 
@return variant,  no retorna valor
/*/
Static Function FGetDirt(oTGet)

	Local cDir 	  := ""

    Default oTGet := Nil
	
	cDir := cGetFile(,STR0043,,,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE)//"Selecionar arquivo"
	If !Empty(cDir)
		oTGet:cText := cDir
		oTGet:Refresh()
	Endif
	oTGet:SetFocus()

Return Nil


/*/{Protheus.doc} ImpFWBSql
Importa el archivo utilizando la función FWBulk. 
@type function
@version  1.0
@author luis.mata
@since 8/28/2024
@param cFile, character, Ubicación y nombre del archivo a importar.
@param cStartPath, character, Ruta del archivo 
@param cfinal, character, nombre Final.
@param cCombo, character, Variable con la opción elegida del combo. 
@return variant,  no retorna valor
/*/
Static Function ImpFWBSql(cFile,cStartPath,cfinal,cCombo)
	Local cLine			:= "" 
	Local aCodeError	:= {}
	Local nX 			:= 0
	Local nUlt 			:= 0
	Local nPosQry 		:= 0
	Local dDataIni 		:= ""
	Local dDataFim 		:= ""	
	Local QRY 			:= GetNextAlias()
	Local QRYEMP 		:= GetNextAlias()
	Local cJoinC 		:= ""
	Local cJoinP 		:= ""
	Local cCGC			:= ALLTRIM(SM0->M0_CGC)
	Local lImp     		:= .F.
	Local aDatos		:= {}
	Local oBulk			:= Nil
	Local lCanUseBulk	:= .F.
	Local aStruct		:= {}
	Local lAuxErro		:= .F. 
	Local cEmpCgc		:= ""
	Local aEmpresa		:= {}
	Local nPosEmp 		:= 0
	Local aLinhas		:= {}
	Local lRet			:= .T.
	Local nPosRazonS	:= 0
	Local nTamRazonS	:= 60
	Local cLinhaErro	:= ""
	Local nCount		:= 0


	Default cFile := ""	
	Default cStartPath := ""
	Default cfinal := ""
	Default cCombo := ""

	IF lAutomato
	 lAuxErro:= lErroSql
	EndIF
	If TCCanOpen("PADRONARER") .Or. lAuxErro
		If !TCDelFile("PADRONARER") .Or. lAuxErro
			UserException( "DROP table error PADRONARER" + CRLF + TCSqlError() )
		EndIf
	EndIf	

	IIf(!lAutomato,aLinhas :=LerArquivo(cStartPath + cfinal),aLinhas :=LerArquivo(cFile))
			

	nUlt:= LEN(aLinhas) 

	aStruct := {}
 
    AADD( aStruct, { 'FECHA1' 	   , 'C' , 008,0 } ) //1
    AADD( aStruct, { 'FECHA2' 	   , 'C' , 008,0 } ) //2
    AADD( aStruct, { 'FECHA3' 	   , 'C' , 008,0 } ) //3
    AADD( aStruct, { 'CUIT'   	   , 'C' , 011,0 } ) //4
    AADD(aStruct,  { "TIPINS"      , 'C' , 001,0 } ) //5
	AADD( aStruct, { 'TIPO2'  	   , 'C' , 001,0 } ) //6
    AADD(aStruct,  { "CAMBIA"      , 'C' , 001,0 } ) //7
    AADD(aStruct,  { "PERALQ"      , 'N' , GetSx3Cache("FH_ALIQ", "X3_TAMANHO"),GetSx3Cache("FH_ALIQ", "X3_DECIMAL")}  )//8
    AADD(aStruct,  { "RETALQ"      , 'N' , GetSx3Cache("FH_ALIQ", "X3_TAMANHO"),GetSx3Cache("FH_ALIQ", "X3_DECIMAL")} ) //9
	AADD(aStruct, { 'GRPPER'  	   , 'N' , 003,0 } ) //10
    AADD(aStruct,  { "GRPRET"      , 'N' , 003,0 } ) //11
    AADD(aStruct,  { "NOME"        , 'C' , 060,0 } ) //12

	nPosRazonS := aScan(aStruct, {|x| x[1] == 'NOME' })
	If nPosRazonS > 0
		nTamRazonS := aStruct[nPosRazonS][3]
	EndIf
	 
    FWDBCreate( 'PADRONARER', aStruct , 'TOPCONN' , .T.) 

	oBulk := FwBulk():New('PADRONARER',2000)
    lCanUseBulk := FwBulk():CanBulk() //  Este método no depende de que la clase FWBulk haya sido inicializada por NEW
    if lCanUseBulk
        oBulk:SetFields(aStruct)
    endif
	if lCanUseBulk 
    	For nX := 1 to nUlt      
			aDatos := aLinhas[nX] 
			If len(aDatos) >= 9
				aDatos[8]  := CVALTOCHAR( aDatos[8])
				aDatos[9]  := CVALTOCHAR( aDatos[9])
				aDatos[8]  := Replace(aDatos[8],',','.')    
				aDatos[9]  := Replace(aDatos[9],',','.')  
				aDatos[8]  := Val(aDatos[8])   
				aDatos[9]  := Val(aDatos[9])   
				aDatos[12] := AllTrim(SubStr(aDatos[nPosRazonS],1,nTamRazonS))
				lRet := oBulk:AddData({aDatos[1],aDatos[2],aDatos[3],aDatos[4],aDatos[5],aDatos[6],aDatos[7],aDatos[8],aDatos[9],aDatos[10],aDatos[11],aDatos[12]})         
				If(!lRet)
					//NOTA: Cuando ocorre un error en la function oBulk:AddData, puede suceder que no se registren todos los datos contenidos en el flush de datos que tiene la linea que generou el error.
					cLinhaErro := getErroBulk(@aCodeError,nX,cLinhaErro,nUlt,oBulk)
				EndIf
			Endif
			aSize(aDatos,0)
		Next
		lImp  := .T.
		nCount := oBulk:NCOUNT
		aSize(aLinhas,0)
	endif 
	
    if lCanUseBulk
		lRet := oBulk:Flush()
		If(!lRet)
			cLinhaErro := getErroBulk(@aCodeError,nX,cLinhaErro,nUlt,oBulk,nCount)
		EndIf
        oBulk:Close()
        oBulk:Destroy()
        oBulk := nil
    endif

	If !Empty(aCodeError)
		MsgAlert(STR0048+Chr(13)+Chr(10)+Chr(13)+Chr(10)+cLinhaErro+".","") //Ocurrió un error al procesar el archivo seleccionado, verifique las siguientes líneas en el archivo:
		aSize(aCodeError,0)
	EndIf

	If lImp 
		aEmpresa := FWLoadSM0()
		nPosEmp := aScan( aEmpresa, {|x| x[2] == cFilAnt } )
		cEmpCgc := Alltrim(aEmpresa[nPosEmp][18])
		If lPer
			BeginSql ALIAS QRYEMP
			SELECT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ 
			FROM PADRONARER PADRON 
			WHERE CUIT = %Exp:cEmpCgc%
			EndSql			
				
			dbSelectArea(QRYEMP)
			Do While (QRYEMP)->(!EOF())
				If !Empty((QRYEMP)->CUIT)
					Aadd(aQry,{(QRYEMP)->CUIT,"I",(QRYEMP)->CAMBIA,(QRYEMP)->RETALQ,(QRYEMP)->PERALQ})
				Endif
				(QRYEMP)->(dbSkip())    
			EndDo	
			(QRYEMP)->(dbCloseArea())
		EndIf 
	
		If Subs(cCombo,1,1) $"2"
			cJoinC := "% PADRONARER PADRON  INNER JOIN "+ RetSqlName("SA1") +" CLIENTE ON PADRON.CUIT = CLIENTE.A1_CGC %""
			BeginSql ALIAS QRY
			SELECT DISTINCT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ 
			FROM  %Exp:cJoinC% 
			WHERE  CLIENTE.%notdel%
			EndSql
		EndIf
		
		If Subs(cCombo,1,1) $"3"	
			cJoinC := "% PADRONARER PADRON  INNER JOIN "+ RetSqlName("SA1") +" CLIENTE ON PADRON.CUIT = CLIENTE.A1_CGC %""
			cJoinP := "% PADRONARER PADRON  INNER JOIN "+ RetSqlName("SA2") +" PROV ON PADRON.CUIT = PROV.A2_CGC %""
			BeginSql ALIAS QRY
			SELECT DISTINCT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ 
			FROM  %Exp:cJoinC% 
			WHERE  CLIENTE.%notdel%
			UNION SELECT DISTINCT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ 
			FROM %Exp:cJoinP%
			UNION SELECT DISTINCT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ
			FROM  PADRONARER PADRON 
			WHERE CUIT = %Exp:cCgc%
			EndSql
		EndIf

		If Subs(cCombo,1,1) $"1"
			
			cJoinP := "% PADRONARER PADRON  INNER JOIN "+ RetSqlName("SA2") +" PROV ON PADRON.CUIT = PROV.A2_CGC %""
			BeginSql ALIAS QRY
			SELECT DISTINCT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ 
			FROM %Exp:cJoinP%
			UNION SELECT DISTINCT CUIT CUIT, CAMBIA CAMBIA,FECHA2 FECHA2,FECHA3 FECHA3,TIPINS TIPINS,PERALQ PERALQ,RETALQ RETALQ
			FROM  PADRONARER PADRON 
			Where CUIT = %Exp:cCgc%
			EndSql
		EndIf

		dbSelectArea(QRY)
		cLine := (QRY)->FECHA2
		dDataIni := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))
		cLine := (QRY)->FECHA3
		dDataFim := STOD(SubStr(cLine,5,4)+SubStr(cLine,3,2)+SubStr(cLine,1,2))     
		Do While (QRY)->(!EOF())
		   nPosQry := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim((QRY)->CUIT)})
	       If nPosQry == 0
	       		Aadd(aQry,{(QRY)->CUIT,"I",(QRY)->CAMBIA,(QRY)->RETALQ,(QRY)->PERALQ})
	       Endif			       
		   (QRY)->(dbSkip())    
		EndDo	
		(QRY)->(dbCloseArea())
		
	EndIf

Return 

/*/{Protheus.doc} FlSFHSql
Actualiza la tabla SFH según los datos del archivo importado. 
@type function
@version  1.0
@author luis.mata
@since 8/28/2024
@param lRet, logical, Variable que indica si efectúa retenciones.
@param lPer, logical, Variable que indica si efectúa percepciones.
@param lCli, logical, Indica si se consulta cliente.
@param lFor, logical, Indica si se consulta Proveedor.
@param dDataIni, date, Fecha de inicio de vigencia
@param dDataFim, date, Fecha de Final de vigencia
@return variant, no retorna valor
/*/
Static Function FlSFHSql(lRet,lPer,lCli,lFor,dDataIni,dDataFim)
	Local cQry			:= ""
	Local cCGC			:= ALLTRIM(SM0->M0_CGC)


	Default lRet		:= .F.
	Default lPer		:= .F.
	Default lCli		:= .F.
	Default lFor		:= .F.
  	Default dDataIni  	:= "" 
	Default dDataFim   	:= "" 
			

	If (lCli .or. lFor) .and. (lPer .or. lRet)
		If lCli .And. lPer
			cQry 	:= " UPDATE "+RetSqlName("SFH")
			cQry 	+= " SET FH_ALIQ = PERALQ " 
			cQry	+= ",FH_ISENTO= CASE PERALQ WHEN '0' THEN 'S' ELSE 'N' END "
			cQry 	+= " FROM "+RetSqlName("SFH")+" SFH,"
			cQry 	+= " "+RetSqlName("SA1")+" SA1 "
			cQry 	+= "INNER JOIN  PADRONARER ARBA " 
			cQry 	+= "ON RTRIM(LTRIM(ARBA.CUIT)) = RTRIM(LTRIM(SA1.A1_CGC)) " 
			cQry 	+= "LEFT JOIN " + RetSqlName("AI0") + " AI0 " 
			cQry 	+= "ON AI0_CODCLI = A1_COD AND AI0_LOJA = A1_LOJA" 
			cQry 	+= " WHERE SFH.D_E_L_E_T_ = '' AND "
			cQry	+= "SFH.FH_FILIAL='"+xFilial("SFH")+"' ""
			cQry	+= " AND SFH.FH_CLIENTE<>'' "
			cQry	+= " AND SFH.FH_IMPOSTO='IBA' "
			cQry	+= " AND SFH.FH_ZONFIS='ER' "
			cQry	+= " AND SA1.A1_FILIAL='"+xFilial("SA1")+"' "
			cQry	+= " AND SA1.A1_CGC<>''  "
			cQry	+= " AND SA1.A1_TIPO<>'E' "
			cQry	+= " AND AI0.AI0_PADRBA <> 'N'"
			cQry	+= " AND SA1.A1_COD=SFH.FH_FORNECE"
			cQry	+= " AND SA1.A1_LOJA=SFH.FH_LOJA "
			cQry	+= " AND ARBA.CUIT=SA1.A1_CGC" 
			cQry	+= " AND SFH.FH_INIVIGE ='"+DToS(dDataIni)+"' "
			cQry	+= " AND SFH.FH_FIMVIGE ='"+DToS(dDataFim)+"' "
			cQry 	+= " AND SA1.D_E_L_E_T_ = '' " 
		EndIf
		If lFor
			If lRet
				cQry 	:= " UPDATE "+RetSqlName("SFH")
				cQry 	+= " SET FH_ALIQ = RETALQ " 
				cQry	+= ",FH_ISENTO= CASE RETALQ WHEN '0' THEN 'S' ELSE 'N' END "
				cQry 	+= " FROM "+RetSqlName("SFH")+" SFH,"
				cQry 	+= " "+RetSqlName("SA2")+" SA2,"
				cQry 	+= "  PADRONARER ARBA " 
				cQry 	+= " WHERE SFH.D_E_L_E_T_ = '' AND "
				cQry	+= "SFH.FH_FILIAL='"+xFilial("SFH")+"' ""
				cQry	+= " AND SFH.FH_FORNECE<>'' "
				cQry	+= " AND SFH.FH_IMPOSTO='IBR' "
				cQry	+= " AND SFH.FH_ZONFIS='ER' "
				cQry	+= " AND SA2.A2_FILIAL='"+xFilial("SA2")+"' "
				cQry	+= " AND SA2.A2_CGC<>''  "
				cQry	+= " AND SA2.A2_TIPO<>'E' "
				cQry	+= " AND SA2.A2_COD=SFH.FH_FORNECE "
				cQry	+= " AND SA2.A2_LOJA=SFH.FH_LOJA  "
				cQry	+= " AND ARBA.CUIT=SA2.A2_CGC "
				cQry	+= " AND SFH.FH_INIVIGE ='"+DToS(dDataIni)+"' "
				cQry	+= " AND SFH.FH_FIMVIGE ='"+DToS(dDataFim)+"' "
				cQry 	+= " AND SA2.D_E_L_E_T_ = '' " 
			EndIf
			If lPer
				cQry 	:= " UPDATE "+RetSqlName("SFH")
				cQry 	+= " SET FH_ALIQ = PERALQ " 
				cQry	+= ",FH_ISENTO= CASE PERALQ WHEN '0' THEN 'S' ELSE 'N' END "
				cQry 	+= " FROM "+RetSqlName("SFH")+" SFH,"
				cQry 	+= " "+RetSqlName("SA2")+" SA2 "
				cQry 	+= "INNER JOIN  PADRONARER ARBA " 
				cQry 	+= "ON RTRIM(LTRIM(ARBA.CUIT)) ='"+%Exp:cCgc%+"' " 
				cQry 	+= " WHERE SFH.D_E_L_E_T_ = '' AND "
				cQry	+= "SFH.FH_FILIAL='"+xFilial("SFH")+"' ""
				cQry	+= " AND SFH.FH_FORNECE<>'' "
				cQry	+= " AND SFH.FH_IMPOSTO='IBA' "
				cQry	+= " AND SFH.FH_ZONFIS='ER' "
				cQry	+= " AND SA2.A2_FILIAL='"+xFilial("SA2")+"' "
				cQry	+= " AND SA2.A2_CGC<>''  "
				cQry	+= " AND SA2.A2_TIPO<>'E' "
				cQry	+= " AND SA2.A2_PADRBA <> 'N'"
				cQry	+= " AND SA2.A2_COD=SFH.FH_FORNECE "
				cQry	+= " AND SA2.A2_LOJA=SFH.FH_LOJA  "
				cQry	+= " AND ARBA.CUIT='"+%Exp:cCgc%+"' " 
				cQry	+= " AND SFH.FH_INIVIGE ='"+DToS(dDataIni)+"' "
				cQry	+= " AND SFH.FH_FIMVIGE ='"+DToS(dDataFim)+"' "
				cQry 	+= " AND SA2.D_E_L_E_T_ = '' " 
			EndIf 
		EndIf 

	EndIf


	If TCSqlExec(cQry) <> 0
		UserException("Update table error " + RetSqlName("SFH") + CRLF + TCSqlError())
	EndIf


Return Nil

/*/{Protheus.doc} GerSFH
Genera registros SFH para todos los clientes/proveedores registrado.
@type function
@version   1.0
@author luis.mata
@since 8/28/2024
@param cFile, character, Ubicación y nombre del archivo a importar.
@param lRet, logical, Variable que indica si efectúa retenciones.
@param lPer, logical, Variable que indica si efectúa percepciones.
@param lCli, logical, Indica si se consulta cliente.
@param lFor, logical, Indica si se consulta Proveedor.
@param dDataIni, date, Fecha de inicio de vigencia
@param dDataFim, date, Fecha de Final de vigencia
@return variant, no retorna valor
/*/
Static Function GerSFH(cFile,lRet,lPer,lCli,lFor,dDataIni,dDataFim)
	Local lFnd			:= .F.
	Local cChave		:= ""  
	Local nPos			:= 0
	Local nRecFim		:= 0
	Local cAgentAnt		:= ""  
	Local cTempSA1 		:= GetNextAlias()
	Local nRecnoSFH		:= 0 
	Local nPosSMO		:= 0
	Local nAliqP		:= 0
	Local nALiq1		:= ""
	Local lAduana		:= .F.

	Default cFile    	:= "" 
	Default lRet		:= .F.
	Default lPer		:= .F.
	Default lCli		:= .F.
	Default lFor		:= .F.
	Default dDataIni    := "" 
	Default dDataFim    := "" 

	If lCli .And. lPer
		BeginSql ALIAS cTempSA1
		SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_CGC, A1_NOME, AI0_PADRBA
		FROM %table:SA1% SA1 INNER JOIN %table:AI0% AI0 ON A1_COD = AI0_CODCLI AND A1_LOJA = AI0_LOJA
		WHERE A1_FILIAL = %xfilial:SA1% 
		AND AI0_FILIAL = %xfilial:AI0%
		AND	SA1.%notdel% AND AI0.%notdel%
		EndSql
		oQryExec := NIL
		Do While xFilial("SA1") == (cTempSA1)->A1_FILIAL .AND. (cTempSA1)->(!EOF())
			If (cTempSA1)->AI0_PADRBA <> "N"
				dbSelectArea("SFH")
				SFH->(dbSetOrder(3))
				SFH->(dbGoTop())
				cAgentAnt:= ""
				lFnd := .F.
				cChave := xFilial("SFH")+(cTempSA1)->A1_COD+(cTempSA1)->A1_LOJA+"IBA"+"ER"    

				nPos := aScan(aQry, {|X| aLLTRIM(X[1]) == ALLTrim((cTempSA1)->A1_CGC)})

				If SFH->(MsSeek(cChave))
					nRecnoSFH := MayorFech((cTempSA1)->A1_COD,(cTempSA1)->A1_LOJA,"IBA",.T.)
					If nRecnoSFH>0 
						lFnd := .T.
					EndIf
				EndIf
			
				If lFnd
					SFH->(DbGoto(nRecnoSFH))
					cAgentAnt:=SFH->FH_AGENTE
					If nPos<>0
						If  aQry[nPos][5] == SFH->FH_ALIQ
							RecLock("SFH",.F.)
							SFH->FH_FIMVIGE := dDataFim
							SFH->(MsUnlock())					
						Else
							lFnd := .F.	
						EndIf
					Else
						If SFH->FH_FIMVIGE >= dDataFim .Or. Empty (SFH->FH_FIMVIGE) .Or. SubStr(DTOS(dDataFim),1,6) == SubStr(DTOS(SFH->FH_FIMVIGE),1,6)
							RecLock("SFH", .F.)
							SFH->FH_FIMVIGE := dDataFim
							SFH->(MsUnlock())
						EndIf
					EndIf
				EndIf				
			
				If !lFnd .And. nPos <> 0
					creaSFH("A1",(cTempSA1)->A1_COD,cAgentAnt,"ER",aQry[nPos][5],aQry[nPos][2],"IBA",(cTempSA1)->A1_LOJA,(cTempSA1)->A1_NOME,"S",dDataIni,dDataFim)							
				EndIf
			EndIf
			(cTempSA1)->(dbSkip())	
		EndDo
		
		(cTempSA1)->(dbCloseArea())
		SFH->(dbCloseArea())

	EndIf 
 	
	If lFor .and. (lRet .or. lPer)
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		SA2->(dbGoTop())
		SA2->(MsSeek(xFilial("SA2")))
		If lPer
	  	nPosSMO:= aScan(aQry, {|X| aLLTRIM(X[1]) ==ALLTrim(SM0->M0_CGC)})
			If nPosSMO>0
				nAliqP:=  aQry[nPosSMO][5]	
			EndIf	   
		EndIf
		dbSelectArea("SFB")
		SFB->( DbSetOrder( 1 ) )
		SFB->(dbGoTop())
		If SFB->(MsSeek(xFilial("SFB")+"IBA"))
			lAduana := IIF( SFB->FB_CLASSE = "P".And. (SFB->FB_TIPO $ "P|M") .And. (SFB->FB_CLASSIF $ "1|5|8"),.T.,.F.)
		EndIf
		oQryExec := NIL
		Do While xFilial("SA2") == SA2->A2_FILIAL .AND.  SA2->(!EOF())
			If (SA2->A2_PADRBA <> "N") .and. !Empty(SA2->A2_CGC)
				If lRet
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					lFnd := .F.
					cAgentAnt:= ""
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBR"+"ER"
					nPos := aScan(aQry, {|X| aLLTRIM(X[1]) ==ALLTrim(SA2->A2_CGC)})
					If SFH->(MsSeek(cChave))
						nRecFim := MayorFech(SA2->A2_COD,SA2->A2_LOJA,"IBR",.F.)
						IF nRecFim>0 
							SFH->(DbGoTo(nRecFim))
							If  nPos<>0 
								IF aQry[nPos][4]==SFH->FH_ALIQ
									lFnd := .T.
									RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
								Else
									lFnd := .T.
									creaSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"ER",aQry[nPos][4],aQry[nPos][2],"IBR",SA2->A2_LOJA,SA2->A2_NOME,"N",dDataIni,dDataFim)	
								EndIf
							Else
								lFnd := .T.
								IF SFH->FH_FIMVIGE >= dDataFim .Or. Empty (SFH->FH_FIMVIGE) .Or. SubStr(DTOS(dDataFim),1,6) == SubStr(DTOS(SFH->FH_FIMVIGE),1,6)
									RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
								EndIf
							EndIf
						EndIf
						
					EndIf
					If !lFnd .And. nPos<>0 //no se encontro en la SFH
						creaSFH("A2",SA2->A2_COD,cAgentAnt,"ER",aQry[nPos][4],aQry[nPos][2],"IBR",SA2->A2_LOJA,SA2->A2_NOME,"N",dDataIni,dDataFim)
					EndIf
				EndIf
				If lPer .And. !(SA2->A2_TIPROV == "A" .And. lAduana)
					dbSelectArea("SFH")
					SFH->(dbSetOrder(1))
					SFH->(dbGoTop())
					If nPosSMO > 0 
						nALiq1:=aQry[nPosSMO][5]
					EndIf 
					cChave := xFilial("SFH")+SA2->A2_COD+SA2->A2_LOJA+"IBA"+"ER"
					If SFH->(MsSeek(cChave))
						nRecFim := MayorFech(SA2->A2_COD,SA2->A2_LOJA,"IBA",.F.)
						IF nRecFim>0 
							SFH->(DbGoTo(nRecFim))
							IF nPosSMO > 0 
								If nALiq1 == SFH->FH_ALIQ
									RecLock("SFH",.F.)							
									SFH->FH_FIMVIGE := dDataFim							
									SFH->(MsUnlock())
								Else
									creaSFH("A2",SA2->A2_COD,SFH->FH_AGENTE,"ER",nALiq1,"I","IBA",SA2->A2_LOJA,SA2->A2_NOME,"S",dDataIni,dDataFim)	
								EndIf
							Else
								IF SFH->FH_FIMVIGE >= dDataFim .Or. Empty (SFH->FH_FIMVIGE) .Or. SubStr(DTOS(dDataFim),1,6) == SubStr(DTOS(SFH->FH_FIMVIGE),1,6)
									RecLock("SFH", .F.)
									SFH->FH_FIMVIGE := dDataFim
									SFH->(MsUnlock())
								EndIf
							EndIf 
						Endif			
						SFH->(MsUnlock())		
						SFH->(dbSkip())
					EndIf 	
				EndIf
			Endif
			SA2->(dbSkip())	
		EndDo
		SA2->(dbCloseArea())
		SFH->(dbCloseArea())
	EndIf

Return Nil

/*/{Protheus.doc} MayorFech
indica la fecha Mayor del registro  
@type function
@version  1.0
@author luis.mata
@since 8/28/2024
@param cCod, character, codigo del  CLi/Pro 
@param cLoja, character, Loja del Cliente 
@param cImpuesto, character, Nombre del Impuesto 
@param lTabla, logical, Nombre de la tabla 
@return nAux, Número del registro encontrado
/*/
Static Function MayorFech(cCod,cLoja,cImpuesto,lTabla)
	Local nAux 		:= 0
	Local nOrd		:= 1
	Local cAlias	:= ""
	Local cQuery	:= ""

	Default cCod 	:= ""	
	Default cLoja 	:= ""
	Default cImpuesto := ""
	Default lTabla := .F.	

	If oQryExec == NIL
        cQuery := " SELECT "
        cQuery += " SFH.FH_FIMVIGE MAX_FECHA, SFH.R_E_C_N_O_"
        cQuery += " FROM " + RetSqlName("SFH") + " SFH "
        cQuery += " WHERE "
        cQuery += " SFH.FH_FILIAL = ? "
		If lTabla
        	cQuery += " AND SFH.FH_CLIENTE = ? "
		Else
			cQuery += " AND SFH.FH_FORNECE = ? "
		EndIf
        cQuery += " AND SFH.FH_LOJA = ? "
        cQuery += " AND SFH.FH_IMPOSTO = ? "
		cQuery += " AND SFH.FH_ZONFIS = ? "
        cQuery += " AND SFH.D_E_L_E_T_ = ? "
        cQuery += " ORDER BY MAX_FECHA DESC"

        cQuery := ChangeQuery(cQuery)
        oQryExec := FwExecStatement():New(cQuery)
    EndIf

    oQryExec:SetString(nOrd++, xFilial("SFH")) //Filial
    oQryExec:SetString(nOrd++, cCod) //Cliente / Proveedor
    oQryExec:SetString(nOrd++, cLoja) //Loja
    oQryExec:SetString(nOrd++, cImpuesto) //Impuesto
    oQryExec:SetString(nOrd++, 'ER') //zona Fiscal
    oQryExec:SetString(nOrd++, ' ') //Delete

	cAlias := oQryExec:OpenAlias()

	IF (cAlias)->(!EOF())
		nAux := (cAlias)->R_E_C_N_O_ 
	EndIf

	(cAlias)->(dbCloseArea())

Return nAux

/*/{Protheus.doc} creaSFH
Crea el nuevo registro en la tabla SFH
@type function
@version  1.0 
@author luis.mata
@since 8/28/2024
@param cTable, character, indica que tabla se va usar A1 o A2  
@param cCOD, character, Código del campo A1_COD O A2_COD 
@param cAgentAnt, character, Valor para el campo FH_AGENTE  
@param cProv, character, Nombre de la Provincia 
@param cAliq, character, alicuota proveniente del (txt) 
@param cTipo, character, valor para el campo FH_TIPO  
@param cImposto, character, valor para el campo FH_IMPOSTO (IBR o IBA) 
@param cLoja, character, valor para el campo FH_LOJA  
@param cNome, character, valor para el campo FH_NOME 
@param cAPERIB, character, Nombre del Archivo 
@param dDataIni, date, Fecha de inicio de vigencia
@param dDataFim, date, Fecha de Final de vigencia
@return variant, no retorna valor
/*/
Function creaSFH(cTable,cCOD,cAgentAnt,cProv,cAliq,cTipo,cImposto,cLoja,cNome,cAPERIB,dDataIni,dDataFim)

Local lCodSFH  := .T.
Local cPrefixo := " "



	Default cTable   	:= "" 
	Default cCOD   	 	:= "" 
	Default cAgentAnt   := "" 
	Default cProv   	:= "" 
	Default cAliq   	:= "" 
	Default cTipo   	:= "" 
	Default cLoja   	:= "" 
	Default cNome   	:= "" 
	Default cImposto   	:= "" 
	Default cAPERIB    	:= "" 
	Default dDataIni   	:= cToD("")
	Default dDataFim   	:= cToD("")

	cPrefixo := "->"+cTable+"_"
	cTable :="S"+cTable
	lCodSFH := IIF(Empty(cCOD),.F.,.T.)

		RecLock("SFH", .T.)
		SFH->FH_FILIAL  := xFilial("SFH")
		If cAgentAnt == ""
			SFH->FH_AGENTE  := "N"
		Else 
			SFH->FH_AGENTE  := cAgentAnt
		EndIf
			SFH->FH_ZONFIS  := cProv
		If cTable == "SA2"
			SFH->FH_FORNECE := IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
		Else
			SFH->FH_CLIENTE	:= IIf(lCodSFH, cCOD , &(cTable+cPrefixo+"COD"))
		EndIf
		SFH->FH_LOJA	:=  cLoja
		SFH->FH_NOME    :=  cNome
		SFH->FH_IMPOSTO := cImposto	
		SFH->FH_PERCIBI := "S"	
		SFH->FH_ISENTO  := "N"
		SFH->FH_APERIB  := cAPERIB
		SFH->FH_ALIQ    := cAliq
		
		If SFH->FH_ALIQ == 0
			SFH->FH_PERCENT	:= 100
			SFH->FH_ISENTO  := "N"
		Else	
			SFH->FH_PERCENT	:= 0
		EndIF
		SFH->FH_COEFMUL := 0
		SFH->FH_INIVIGE := dDataIni
		SFH->FH_FIMVIGE := dDataFim
		SFH->FH_TIPO := cTipo
		SFH->(MsUnlock())
	
	
Return 


/*/{Protheus.doc} FIS842AUT
Función utilizada para automatización ADVPR
@type function
@version  1.0 
@author luis.mata
@since 8/28/2024
@param cArchivo, character, caracter,ruta del padron a cargar. 
@param cCombo, character, indica si es cliente proveedor o ambos 
@param lError, logico, parametro para acceder a errores sql 
@param lVal, logico,auxiliar para validar por automatizado cuando es fecha diferente del periodo 
				o periodo vacío.
@return variant, no retorna valor
/*/
Function FIS842AUT(cArchivo,cCombo,lError,lVal)
	Local aCombo :={}

	
	Private cFileAut:=cArchivo
	Private aQry := {}
	private lErroSql:= .F.

	Default cArchivo	:= " "
	Default cCombo		:= " "
	Default lError		:= .F.
	DEFAULT lVal		:=.F.

	lErroSql := lError

	aAdd( aCombo, "1- Proveedor" ) //"1- Fornecedor"
	aAdd( aCombo, "2- Cliente" ) //"2- Cliente"
	aAdd( aCombo, "3- Ambos" ) //"3- Ambos"

	IF FILE(cArchivo) .and. !lVal
		ImpoArq(aCombo,cCombo)
	EndIf
	If lVal
		ImpoArq(aCombo,cCombo,lVal)
	EndIF

Return nil


/*/{Protheus.doc} LerArquivo
Función utilizada para automatización ADVPR
@type function
@version  1.0 
@author igor.manrique
@since 11/22/2024
@param cArquivo, character, caracter,ruta del padron a cargar. 
@return aRet, Array com os dados do arquivo importado
/*/
Static Function LerArquivo(cArquivo)
	Local aRet    := {}
	Local cBuffer := ""
	Local oFile   := Nil

	Default cArquivo := ""

	oFile	:= FwFileReader():New(cArquivo)
	
	If (oFile:Open())
        While (oFile:HasLine())

			cBuffer := oFile:GetLine()
			cBuffer := Alltrim(cBuffer)
			If !Empty(cBuffer)
				aadd(aRet,separa(cBuffer,_SEPARADOR))
			Endif
		EndDo
		
		oFile:Close()
	EndIf

	If Empty(aRet)
		Help(" ",1, STR0045)
	Endif
	
Return aRet

/*/{Protheus.doc} fDelFile
Función utilizada borrar archivo cargado 
@type function
@version  1.0 
@author adrian.perez
@since 08/12/2024
@param lCopy, booleano, indica si existió una copia del archivo cargado a la carpeta indicada por (GetSrvProfString("StartPath","")) 
@param cArchDel, carácter, ruta y nombre del archivo a borrar
@param lVal, logico,auxiliar para validar por automatizado cuando es fecha diferente del periodo 
				o periodo vacío.
@return nil
/*/

Static Function fDelFile(lCopy,cArchDel,lVal)


DEFAULT lCopy:=.F.
DEFAULT cArchDel:=""
DEFAULT lVal:=.F.

	IF  lCopy .OR. lVal
		FERASE(cArchDel)
	ENDIF

Return nil

/*/{Protheus.doc} getErroBulk
Función utilizada para obtener la linea del archivo que hubo error.
@type function
@version  1.0 
@author pedro.candido
@since 25/04/2025
@param aCodeError, array, array con los errores que ocorreu en el flush de datos del oBulk
@param nX, numeric, numero del registro que estas posicionado
@param cLinhaErro, character, varibale con las lineas que ocorreram orrores.
@param nUlt, numeric, numero de la linea del ultimo registro del archivo de importación 
@param oBulk, object.
@param nCount, numeric, cuantidade de registros del oBulk
@return cLinhaErro, character 
/*/

Static Function getErroBulk(aCodeError,nX,cLinhaErro,nUlt,oBulk,nCount)

Local cGetLinha		:= ""
Local cGetRowErr	:= ""
Local nAt			:= 0

DEFAULT aCodeError := {}
DEFAULT nX		   := 0
DEFAULT cLinhaErro := ""
DEFAULT nUlt	   := 0
DEFAULT oBulk	   := nil
DEFAULT nCount	   := 0

cGetRowErr := SubStr(oBulk:GetError(),At("Row",oBulk:GetError())+4,4)
nAt := At(" ",cGetRowErr)

If nAt > 0
	cGetRowErr := padr(cGetRowErr,nAt-1)
EndIf

	If nUlt > oBulk:NLIMIT .and. nCount == 0
		cGetLinha := AllTrim(Str(nX-oBulk:NLIMIT-1 + Val(cGetRowErr)))
	ElseIf nUlt > oBulk:NLIMIT .and. nCount > 0
		cGetLinha := AllTrim(Str(nX-nCount-1 + Val(cGetRowErr)))
	Else
		cGetLinha := AllTrim(Str(Val(cGetRowErr)))
	EndIf
	Aadd(aCodeError,{cGetLinha + " - " + oBulk:GetError()})
	If Empty(cLinhaErro)
		cLinhaErro := cGetLinha
	ElseIf Len(aCodeError) < 100
		cLinhaErro += ", " + cGetLinha
	EndIf

Return cLinhaErro
