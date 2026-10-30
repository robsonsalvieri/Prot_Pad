#Include 'protheus.ch'
#Include 'GPEXFUMI.ch'
#Include "SHELL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GPEXFUMI  ³Autor  ³Luis E. Enríquez Mata  ³  Data ³  21/11/19   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³ Funciones genéricas GPE Mercado Internacional.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³Fecha   ³   Issue   ³ Motivo de la alteración                ³±±
±±³Luis Enriquez³21/11/19³DMINA-7532 ³Creación de funciones para carga de Ti- ³±±
±±³             ³        ³           ³pos de ausencia (MEX)                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*/{Protheus.doc} GPXCARRCM
Ejecución de función GPXRCM estándar por país.
@type function
@author luis.enríquez
@since 21/11/2019
@version 1.0
@return Nil
/*/
Function GPXCARRCM()
	Local cFunction	:= ("GPXRCM" + cPaisLoc)
	Private aRCMEnc := {}
	Private aRCMDet := {}	
	
	If FindFunction(cFunction)
		bFunc := __ExecMacro("{ ||  " + cFunction + "() }")
		Eval(bFunc)
	EndIf
Return Nil

/*/{Protheus.doc} GPXRCMMEX
Ejecución de regla de negocio para carga de tabla Tipos de Ausencia (RCM) para 
el país México.
@type function
@author luis.enríquez
@since 21/11/2019
@version 1.0
@return Nil
/*/
Function GPXRCMMEX()
	Local cFunGPPD := "GPPD" + Alltrim(cPaisLoc)

	Private aGPError  := {}
	Private nDatosErr := 0
		
	If !ChkVazio("RCM",.F.)
		If !ChkVazio("SRV",.F.)
			cMsgYesNo	:= OemToAnsi(;
								STR0001 + ;	//"No existen registros de Conceptos (SRV)"
								CRLF	+ ;	
								StrTran( STR0002, "###", STR0005 ) + ;	//"¿Desea generar los ### estándar?" //"Conceptos"
								CRLF	+ ;
								STR0003  + cPaisLoc + STR0004 ;	//"Importante: Es necesario que el programa GPPD" //".PRX este compilado."
	                            )
			If MsgYesNo(OemToAnsi(cMsgYesNo) , OemToAnsi(STR0005)) //"Conceptos"
				If FindFunction("fCarPD")
					If FindFunction(cFunGPPD)
						Processa( { || fCarPD() } , OemToAnsi(StrTran( STR0006, "###", STR0005 )) ) //"Cargando los ### estándar..." //"Conceptos"
					Else
						MsgAlert(STR0007 + cFunGPPD + STR0008, OemToAnsi(STR0009)) //El programa " //".PRX no esta compilado en el repositorio." //"Atención"						
					EndIf
				EndIf
		    EndIf                            
		EndIf
		
		If !ChkVazio("SRV",.F.)
			 MsgAlert(STR0010, OemToAnsi(STR0009)) //"No se encuentran cargados los Conceptos (SRV), datos requeridos para continuar con el proceso." //"Atención"		
		Else
			If MsgYesNo(OemToAnsi(STR0025 + ;       //"No existen registros de Tipos de Ausencia (RCM)" 
				CRLF + StrTran( STR0002, "###", STR0011 )) , OemToAnsi(STR0011)) //"¿Desea generar los ### estándar?" //"Tipos de Ausencia"
				
				Processa( { || GpexCrgRCM()} , OemToAnsi(StrTran(STR0006, "###", STR0011)) ) //"Cargando los ### estándar..." //"Tipos de Ausencia"

			EndIf
		EndIf	
	EndIf
Return Nil


/*/{Protheus.doc} GPXRCMCOL
Ejecución de regla de negocio para carga de tabla Tipos de Ausencia (RCM) para 
el país Colombia.
@type function
@author diego.rivera
@since 23/11/2020
@version 1.0
@return Nil
/*/
Function GPXRCMCOL()
	Local cFunGPPD		:= "GPPD" + Alltrim(cPaisLoc)

	Private aGPError	:= {}
	Private nDatosErr	:= 0
		
	If !ChkVazio("RCM",.F.)
		If !ChkVazio("SRV",.F.)
			cMsgYesNo	:= OemToAnsi(;
								STR0001 + ;	//"No existen registros de Conceptos (SRV)"
								CRLF	+ ;	
								StrTran( STR0002, "###", STR0005 ) + ;	//"¿Desea generar los ### estándar?" //"Conceptos"
								CRLF	+ ;
								STR0003  + cPaisLoc + STR0004 ;	//"Importante: Es necesario que el programa GPPD" //".PRX este compilado."
	                            )
			If MsgYesNo(OemToAnsi(cMsgYesNo) , OemToAnsi(STR0005)) //"Conceptos"
				If FindFunction("fCarPD")
					If FindFunction(cFunGPPD)
						Processa( { || fCarPD() } , OemToAnsi(StrTran( STR0006, "###", STR0005 )) ) //"Cargando los ### estándar..." //"Conceptos"
					Else
						MsgAlert(STR0007 + cFunGPPD + STR0008, OemToAnsi(STR0009)) //El programa " //".PRX no esta compilado en el repositorio." //"Atención"						
					EndIf
				EndIf
		    EndIf                            
		EndIf
		
		If !ChkVazio("SRV",.F.)
			 MsgAlert(STR0010, OemToAnsi(STR0009)) //"No se encuentran cargados los Conceptos (SRV), datos requeridos para continuar con el proceso." //"Atención"		
		Else			
			If MsgYesNo(OemToAnsi(STR0025 + ; //"No existen registros de Tipos de Ausencia (RCM)" 
				CRLF + StrTran( STR0002, "###", STR0011 )) , OemToAnsi(STR0011)) //"¿Desea generar los ### estándar?" //"Tipos de Ausencia"
				
				Processa( { || GpexCrgRCM()} , OemToAnsi(StrTran(STR0006, "###", STR0011)) ) //"Cargando los ### estándar..." //"Tipos de Ausencia"

			EndIf
		EndIf	
	EndIf
Return Nil

/*/{Protheus.doc} fCarRCM
Llenado de tabla Tipos de Ausencia (RCM)
@type function
@author luis.enríquez
@since 21/11/2019
@version 1.0
@param aRCMCab, array, Arreglo con nombre de campos de la tabla RCM.
@param aRCMDet, array, Arreglo con los valores para los campos de la tabla RCM.
@param nDatosErr, numerico, Contador con número de registros que tuvieron error al insertar en la tabla RCM.
@return Nil
/*/
Function fCarRCM(aRCMCab, aRCMDet, nDatosErr)
	Local nI := 0
	Local nY := 0
	Local cFilRCM := xFilial("RCM")
	Local cFilSRV := xFilial("SRV")
	Local lError  := .F.
	
	ProcRegua(Len(aRCMDet))
	
	BEGIN TRANSACTION
		For nI := 1 to Len(aRCMDet)
			IncProc(Alltrim(aRCMDet[nI,1]) + Alltrim(aRCMDet[nI,2]))
			RCM->(dbSetOrder(1)) //RCM_FILIAL + RCM_TIPO
			If !RCM->( dbSeek( cFilRCM + aRCMDet[nI,1]))
				RCM->(RecLock("RCM" , .T.))
				RCM->RCM_FILIAL := cFilRCM
				For nY := 1 to Len(aRCMCab)
					lError  := .F.
					If aRCMCab[nY] == "RCM_PD"
						dbSelectArea("SRV")
						SRV->(dbSetOrder(1)) //RV_FILIAL + RV_COD
						If SRV->(dbSeek(cFilSRV + aRCMDet[nI,nY]))
							RCM->(&(aRCMCab[nY])) := aRCMDet[nI,nY]
						Else
							aRCMDet[nI,12] += STR0015 + Alltrim(aRCMDet[nI,3]) + STR0016 //"El código del Concepto " //" para el tipo de ausencia no existe."
							lError := .T. 
						EndIf
					Else
						RCM->(&(aRCMCab[nY])) := aRCMDet[nI,nY]
					EndIf
					If lError
						aRCMDet[nI,11] := .T. 
						nDatosErr += 1
					EndIf
				Next nY
				RCM->(MsUnLock())  
			EndIf
		Next nI
			
		If nDatosErr > 0
			DisarmTransaction()
		EndIf		
	END TRANSACTION
Return Nil

/*/{Protheus.doc} GPXGENLOG
Generación de la impresión del LOG del proceso.
@type function
@author luis.enríquez
@since 21/11/2019
@version 1.0
@param aProcesa, array, Arreglo con los registros procesados.
@param cTipo, string, Nombre de los datos procesados (Ej. "Conceptos", "Tipos de Ausencia")
@param nDatosErr, numerico, Contador con número de registros que tuvieron error al insertar en la tabla RCM.
@return Nil
/*/
Static function GPXGENLOG(aProcesa, cTipo, nDatosErr)
	Local aReturn	:= {"xxxx", 1, "yyy", 2, 2, 1, "",1 }
	Local cTamanho	:= "M"
	Local cTitulo	:= STR0017 + cTipo //"LOG generación de "
	Local nX		:= 1
	Local aNewLog	:= {}
	Local nTamLog	:= 0
	Local aLogTitle	:= { STR0018, STR0019 }   //"Tipo Descripción                  Observaciones" //"Resumen del proceso"
	Local aLog		:= {}
	Local cEsp		:= Chr(9) + Chr(9)+ Chr(9)
	Local aLogRes	:= {}
	Local cObs      := ""
	Local nPos 		:= 1
	Local nC		:= 0
	Local nError    := 0
	
	Private wCabec1 := STR0020 + cTipo  //"Datos procesados: "
	
	ASORT(aProcesa, , , { | x,y | x[1] + x[2]  > y[1] + y[2] } )
	
	For nX :=1 To Len(aProcesa)                 
		cObs := ""
		nPos := 1
		If Len(aProcesa[nX,12]) > 84
			For nC:= 1 to (Len(aProcesa[nX,12]) / 84) + 1				 
				cObs += SubStr(aProcesa[nX,12], nPos, 84)  + (Chr(13) + Chr(10)) + Space(40)
				nPos += 84
			Next nC			
		Else
			cObs := aProcesa[nX,12]
		EndIF
		                           
	    aAdd(aLog, aProcesa[nx,1] + Space(2) + ;   //Tipo
	    		   aProcesa[nX,2] + Space(16) + ;  //Descripción
	    		   cObs )                         // Detalle	 	    		 
	Next nX
		
	aAdd(aLogRes," ")
	If nDatosErr > 0
		aadd(aLogRes,STR0021 + Transform(Len(aProcesa),"9999"))    //"Registros Válidos:"
		aadd(aLogRes,STR0022 + Transform(nDatosErr,"9999"))		//"Registros Erróneos:"
	Else
		aadd(aLogRes,STR0023 + Transform(Len(aProcesa),"9999"))  //"Registros Generados:"
	EndIf

	aNewLog		:= aClone(aLog)
	nTamLog		:= Len( aLog)	
	aLog := {}
	
	If !Empty( aNewLog )	
		aAdd( aLog , aClone( aNewLog ) )
	Endif
	
	aAdd(aLog, aLogRes)
	/*
		1 -	aLogFile 	//Array que contem os Detalhes de Ocorrencia de Log
		2 -	aLogTitle	//Array que contem os Titulos de Acordo com as Ocorrencias
		3 -	cPerg		//Pergunte a Ser Listado
		4 -	lShowLog	//Se Havera "Display" de Tela
		5 -	cLogName	//Nome Alternativo do Log
		6 -	cTitulo		//Titulo Alternativo do Log
		7 -	cTamanho	//Tamanho Vertical do Relatorio de Log ("P","M","G")
		8 -	cLandPort	//Orientacao do Relatorio ("P" Retrato ou "L" Paisagem )
		9 -	aRet		//Array com a Mesma Estrutura do aReturn
		10-	lAddOldLog	//Se deve Manter ( Adicionar ) no Novo Log o Log Anterior
	*/
	Processa( { ||fMakeLog( aLog ,aLogTitle , , .t. , FunName() , cTitulo , cTamanho , "P" , aReturn, .F. )}, STR0024 + cTipo) //"Generando Log de creación de "	
Return Nil

/*/{Protheus.doc} GpexRGXMI
	Función utilizada para ejecutar las funciones que generan los PRX de MI,
	correspondientes a Estandar de Periodos y Criterios de Acumulación.
	Los archivos generados dependerán del país. GPRGX + cPaisLoc + .prx y 
	GPRG9 + cPaisLoc+ .prx

	@type  Function
	@author marco.rivera
	@since 25/09/2022
	@version 1.0
	@example
	GpexRGXMI()
	/*/
Function GpexRGXMI(cPath, aListaArch)

	Local aLinesProg 	:= {}	// array com as linhas dos programas  
	Local aLinProg2     := {}	// array com as linhas dos programas
	Local aIniHdrRG5	:= {}	// cabecalho da tabela RG5 com os campos
	Local aRG5Virtual	:= {}	// campos virtuais de RG5
	Local aIniHdrRG6	:= {}	// cabecalho da tabela RG6 com os campos
	Local aRG6Virtual	:= {}	// campos virtuais de RG6
	Local aIniHdrRG9	:= {}	// cabecalho da tabela RG9 com os campos
	Local aRG9Virtual	:= {}	// campos virtuais de RR9

	Local cArquivo 		:= ""	// nome do arquivo a ser gerado
	Local cArquivo2     := ""   // nome do arquivo a ser gerado

	Local cMsg			:= ""	// mensagem de erro na geracao do arquivo PRX
	Local cProg			:= ""	// string a ser enviado ao arquivo PRX
	Local cValueCampo	:= ""	// montagem da string a ser enviado ao array
	Local cTexto		:= ""	// valor do campo do Header

	Local nArq		// situacao do arquivo
	Local nArq2		// situacao do arquivo
	Local nUsado	// campos utilizados

	Local nX			:= 0
	Local nY			:= 0

	Local cNomArch1		:= ""
	Local cNomArch2		:= ""

	Default	cPath		:= "" //Ruta donde se grabarán los archivos
	Default aListaArch	:= {} //Contiene la lista de archivos que fueron generados previamente

	cArquivo 	:= ("GPRGX" + cPaisLoc + ".PRX")
	cArquivo2 	:= ("GPRG9" + cPaisLoc + ".PRX")
	cNomArch1	:= cArquivo
	cNomArch2	:= cArquivo2

	aIniHdrRG5	:= RG5->( GdMontaHeader( @nUsado, @aRG5Virtual, NIL, NIL, NIL, .T.,.T. ) )
	aIniHdrRG6	:= RG6->( GdMontaHeader( @nUsado, @aRG6Virtual, NIL, NIL, NIL, .T.,.T. ) ) 
	aIniHdrRG9	:= RG9->( GdMontaHeader( @nUsado, @aRG9Virtual, NIL, NIL, NIL, .T.,.T. ) )

	Begin Sequence
	
	cArquivo  := cPath + cArquivo
	cArquivo2 := cPath + cArquivo2	

	If File(cArquivo)
		If !(MsgYesNo(STR0026 + cNomArch1 + STR0027 + cArquivo, STR0028)) //"¡El archivo " - " ya existe!, ¿Desea sobreescribir? " - "¡Atención!"
			Break
		EndIf
	EndIf 

	If File(cArquivo2)
		If !(MsgYesNo(STR0026 + cNomArch2 + STR0027 + cArquivo2, + STR0028)) //"¡El archivo " - " ya existe!, ¿Desea sobreescribir? " - "¡Atención!"
			Break
		EndIf
	EndIf
	
	nArq := MSFCREATE(cArquivo, 0)
	If Ferror() # 0 .And. nArq = -1
		cMsg := STR0029 + STR(Ferror(),3) //"Error en la grabación del archivo - Código DOS: "
		MsgInfo(cMsg, STR0028)
		Return(.F.)
	EndIf

	nArq2 := MSFCREATE(cArquivo2, 0)
	If Ferror() # 0 .And. nArq2 = -1
		cMsg := STR0029 + STR(Ferror(),3) //"Error en la grabación del archivo - Código DOS: "
		MsgInfo(cMsg, STR0028)
		Return(.F.)
	EndIf

	// Encabezado de la Función
	aAdd(aLinesProg, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³Fun‡…o    ³GpRGX" + cPaisLoc + "      " + "³Autor³ TOTVS       ³ Data ³" + SubStr(DtoS(date()),7,2)+"/"+SubStr(DtoS(date()),5,2)+"/"+SubStr(DtoS(date()),1,4) + "        ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Descri‡…o ³Estándar de Periodos                                        ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Sintaxe   ³                                                            ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Parametros³Ver parámetros formales                                     ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³ Uso      ³Genérico                                                    ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, "Function GpRGX" + cPaisLoc + "(aItensRG6, aRG6Header, aItensRG5, aRG5Header)" + CRLF +  CRLF)
	
	aAdd(aLinesProg, "Local lRet		:= .T." + CRLF + CRLF)
	
	aAdd(aLinesProg, "Default aItensRG6   := {}" + CRLF)
	aAdd(aLinesProg, "Default aRG6Header  := {}" + CRLF)
	aAdd(aLinesProg, "Default aItensRG5   := {}" + CRLF)
	aAdd(aLinesProg, "Default aRG5Header  := {}" + CRLF + CRLF)	
	
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Encabezado de RG6 generado por el Procedimiento estándar     ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRG6)
		cProg      := ""
		For nY := 1 To Len(aIniHdrRG6[nX])
			cTexto := If(ValType(aIniHdrRG6[nX,nY])=="N", AllTrim(Str(aIniHdrRG6[nX,nY])),;
						   	If(ValType(aIniHdrRG6[nX,nY])=="L", Transform(aIniHdrRG6[nX, nY],"@!"),;
						   	   aIniHdrRG6[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRG6[nX])
				cProg += ","
			EndIf
		Next nY
		If !Empty(cProg)
			cTela := AllTrim(GetSx3Cache( aIniHdrRG6[nX][2], "X3_TELA" ))
			If !Empty(cTela)
				aAdd(aLinesProg, "IIf( MV_MODFOL = '" + cTela + "', aAdd(aRG6Header, " + '{ ' + cProg + ' })' + ", '')" + CRLF)
			Else
				aAdd(aLinesProg, "aAdd(aRG6Header, " + '{ ' + cProg + ' })' + CRLF)
			EndIf
		EndIf
	Next nX

	aAdd(aLinesProg, CRLF)

    //Ítems de RG6
	DbSelectArea("RG6")
	RG6->(DBSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG
	RG6->(DBGoTop())

	While !RG6->(EoF())

	 	cProg := "	aAdd(aItensRG6, { "
		For nX := 1 To Len(aIniHdrRG6)
			cValueCampo := ""

			If aIniHdrRG6[nX,8] == "N"
				cValueCampo += AllTrim(Str(&(aIniHdrRG6[nX,2])))
			ElseIf "FILIAL" $ aIniHdrRG6[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += &(aIniHdrRG6[nX,2])
			EndIf

			cValueCampo := StrTran(cValueCampo, "'", '"')
	
			If (aIniHdrRG6[nX,8] != "N") .and. (aIniHdrRG6[nX,8] != "D") .and. (aIniHdrRG6[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf
	
			cProg += cValueCampo
			If nX < Len(aIniHdrRG6)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		aAdd(aLinesProg, cProg + CRLF)
		RG6->(dbSkip())

	EndDo
	
	aAdd(aLinesProg, "" + CRLF)
	aAdd(aLinesProg, "" + CRLF)
	aAdd(aLinesProg, "" + CRLF)

	//Monta encabezado de RG5
	For nX := 1 To Len(aIniHdrRG5)
		cProg := ""
		For nY := 1 To Len(aIniHdrRG5[nX])
			cTexto := If(ValType(aIniHdrRG5[nX,nY])=="N", AllTrim(Str(aIniHdrRG5[nX,nY])),;
						   	If(ValType(aIniHdrRG5[nX,nY])=="L", Transform(aIniHdrRG5[nX, nY],"@!"),;
						   	   aIniHdrRG5[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRG5[nX])
				cProg += ","
			EndIf
		Next nY
		If !Empty(cProg)
			aAdd(aLinesProg, "aAdd(aRG5Header, " + '{ ' + cProg + ' })' + CRLF)
		EndIf
	Next nX
	aAdd(aLinesProg, CRLF)
	
	//Ítems de RG5
	DbSelectArea("RG5")
	RG5->(dbGoTop())
	RG5->(dbSetOrder(RetOrder("RG5", "RG5_FILIAL+RG5_PDPERI")))

	While !RG5->(Eof())

	 	cProg := "	aAdd(aItensRG5, { "
		For nX := 1 To Len(aIniHdrRG5)
			cValueCampo := ""

			If "FILIAL" $ aIniHdrRG5[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += &(aIniHdrRG5[nX,2])
			EndIf

			cValueCampo := StrTran(cValueCampo, "'", '"')

			If (aIniHdrRG5[nX,8] != "N") .and. (aIniHdrRG5[nX,8] != "D") .and. (aIniHdrRG5[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf
	
			cProg += cValueCampo
			If nX < Len(aIniHdrRG5)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		aAdd(aLinesProg, cProg + CRLF)
		RG5->(dbSkip())

	EndDo

	aAdd(aLinesProg, CRLF)
	aAdd(aLinesProg, 'Return ( lRet )' + CRLF)  

	//Encabezado de la Función
	aAdd(aLinProg2, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinProg2, "/*/" + CRLF)
	aAdd(aLinProg2, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinProg2, "³Fun‡…o    ³GpRG9" + cPaisLoc + "     " + "³Autor³ TOTVS ³ Data ³" + SubStr(DtoS(date()),7,2)+"/"+SubStr(DtoS(date()),5,2)+"/"+SubStr(DtoS(date()),1,4) + "               ³" + CRLF)
	aAdd(aLinProg2, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinProg2, "³Descri‡…o ³Criterios de Acumulación                                    ³" + CRLF)
	aAdd(aLinProg2, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinProg2, "³Sintaxe   ³                                                            ³" + CRLF)
	aAdd(aLinProg2, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinProg2, "³Parametros³Ver parámetros formales                                     ³" + CRLF)
	aAdd(aLinProg2, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinProg2, "³ Uso      ³Genérico                                                    ³" + CRLF)
	aAdd(aLinProg2, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinProg2, "Function GpRG9" + cPaisLoc + "(aItensRG9, aRG9Header)" + CRLF + CRLF)
	
	aAdd(aLinProg2, "Local lRet		:= .T." + CRLF + CRLF)
	
	aAdd(aLinProg2, "Default aItensRG9	:= {}" + CRLF)
	aAdd(aLinProg2, "Default aRG9Header	:= {}" + CRLF + CRLF)                          
	
	aAdd(aLinProg2, "/*/" + CRLF)
	aAdd(aLinProg2, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinProg2, "³ Encabezado de RG9 generado por el Procedimiento estándar    ³" + CRLF)
	aAdd(aLinProg2, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRG9)
		cProg := ""
		For nY := 1 To Len(aIniHdrRG9[nX])
			cTexto := If(ValType(aIniHdrRG9[nX,nY])=="N", AllTrim(Str(aIniHdrRG9[nX,nY])),;
						   	If(ValType(aIniHdrRG9[nX,nY])=="L", Transform(aIniHdrRG9[nX, nY],"@!"),;
						   	   aIniHdrRG9[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRG9[nX])
				cProg += ","
			EndIf
		Next nY
		If !Empty(cProg)
			aAdd(aLinProg2, "aAdd(aRG9Header, " + '{ ' + cProg + ' })' + CRLF)
		EndIf
	Next nX

	aAdd(aLinProg2, CRLF)

	//Ítems de Tipo de Cálculo
	DbSelectArea("RG9")
	RG9->(DBSetOrder(1)) //RG9_FILIAL+ RG9_CODCRI
	RG9->(DBGoTop())
		
	While !RG9->(Eof())
	 
	 	cProg := "	aAdd(aItensRG9, { "
		For nX := 1 To Len(aIniHdrRG9)
			cValueCampo := ""
	
			If aIniHdrRG9[nX,8] == "N"
				cValueCampo += AllTrim(Str(&(aIniHdrRG9[nX,2])))
			ElseIf "FILIAL" $ aIniHdrRG9[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += &(aIniHdrRG9[nX,2])
			EndIf

			cValueCampo := StrTran(cValueCampo, "'", '"')
	
			If (aIniHdrRG9[nX,8] != "N") .and. (aIniHdrRG9[nX,8] != "D") .and. (aIniHdrRG9[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf

			cProg += cValueCampo
			If nX < Len(aIniHdrRG9)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		aAdd(aLinProg2, cProg + CRLF)
		RG9->(dbSkip())

	EndDo

	aAdd(aLinProg2, "" + CRLF)

	aAdd(aLinProg2, CRLF)
	aAdd(aLinProg2, 'Return ( lRet )' + CRLF + CRLF)

	//Transfiere las líneas al programa
    For nX := 1 To Len(aLinesProg)
	    Fwrite( nArq, aLinesProg[nX] )
	Next nX

	FClose(nArq)  

	//Transfiere las líneas al programa
    For nX := 1 To Len(aLinProg2)
	    Fwrite( nArq2, aLinProg2[nX] )
	Next nX

	FClose(nArq2)

	aAdd(aListaArch, cNomArch1) //"GPRGX" + cPaisLoc + ".PRX"
	aAdd(aListaArch, cNomArch2) //"GPRG9" + cPaisLoc + ".PRX"

	End Sequence

Return Nil

/*/{Protheus.doc} GpexDelRGX
	Función utilizada para eliminar registros de las tablas RG5, RG6 y RG9; para
	preparar la carga de información estándar.

	@type  Static Function
	@author marco.rivera
	@since 28/09/2022
	@version 1.0
	@example
	GpexDelRGX()
/*/
Function GpexDelRGX()

	Local cModFol	:= SuperGetMV("MV_MODFOL", .F., "2") //Parámetro para determinar el modelo de la rutina.

	RG9->(DbGoTop())
	RG9->(DbSetOrder(1)) //RG9_FILIAL+RG9_CODCRI

	While RG9->(!EoF())

		RG6->(DbGoTop())
		RG6->(DbSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG

		While RG6->( !Eof())
			If RG6->(RG6_FILIAL+AllTrim(RG6_CRITER)) == RG9->(RG9_FILIAL+RG9_CODCRI)
				If (cModFol == "2") //Si es Modelo 2, borra registros de RG5
					RG5->(DbSeek(RG6->( RG6_FILIAL + RG6_PDPERI ) , .F. ) )
					While RG5->( !Eof() ) .And. (RG5->(RG5_FILIAL + RG5_PDPERI) == RG6->(RG6_FILIAL + RG6_PDPERI))
						If RG5->(RecLock("RG5", .F. , .F.))
							RG5->(DBDelete())
							RG5->(MsUnLock())
						EndIf
						RG5->(DBSkip())
					EndDo
				EndIf
				If RG6->(RecLock( "RG6", .F., .F.))
					RG6->(DBDelete())
					RG6->(MsUnLock())
				EndIf
			EndIf
			RG6->(DBSkip())
		EndDo
		If RG9->(RecLock("RG9", .F., .F.))
			RG9->(DBDelete())
			RG9->(MsUnLock())
		EndIf
	 	RG9->( DBSkip() )
	EndDo
	
Return Nil

/*/{Protheus.doc} GpexCrgRGX
	Función utilizada para cargar los registros de las Tablas de Estandar de Periodos 
	RG5 y RG6 a partir de conceptos por procesos.

	@type  Function
	@author marco.rivera
	@since 28/09/2022
	@version 1.0
	@example
	GpexCrgRGX()
	/*/
Function GpexCrgRGX()

	Local aArea		:= GetArea()
	Local aAreaRG5	:= RG5->(GetArea())
	Local aAreaRG6	:= RG6->(GetArea())  
	Local aAux		:= {}
	Local aAuxRG5   := {}
	Local aRG5Header:= {}
	Local aRG6Header:= {}
	Local bFunc		:= {|| NIL}
	Local cCampo	:= ""
	Local cFilRG5	:= xFilial("RG5")
	Local cFilRG6	:= xFilial("RG6")
	Local cEstper	:= ""
	Local cEstped   := ""
	Local cFunRGX	:= ("GPRGX" + cPaisLoc)
	Local nFieldPos
	Local nPosField
	Local nPosEstPer
	Local nPosEstPed
	Local nPosEstCod
	Local nPosEstNum
	Local nAux
	Local nAuxRG6
	Local nAuxs
	Local nAuxsRG6
	Local nX
	Local uCnt
	Local cFiltro := 'RG5->RG5_FILIAL == "' + cFilRG5+ '"' 
	Local cFiltro1 := 'RG6->RG6_FILIAL == "' + cFilRG6 + '"' 
	Local bFiltro := { || &(cFiltro) }
	Local bFiltro1 := { || &(cFiltro1) }

	//Valida que exista la función del país actual
	If FindFunction(cFunRGX)
		bFunc := __ExecMacro("{ ||  " + cFunRGX + "( @aAux , @aRG6Header, @aAuxRG5 , @aRG5Header ) }")
		Eval(bFunc)
		DbSelectarea("RG5")
		RG5->(DbSetOrder(1)) //RG5_FILIAL+RG5_PDPERI
		DbSelectarea("RG6")
		RG6->(DbSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG
		RG5->(DbSetfilter( bFiltro, cFiltro ))
		RG5->(DbGoTop())
		RG6->(DbSetfilter( bFiltro1, cFiltro1 ))
		RG6->(DbGoTop())
			
		//Verifica si la tabla estándar de periodos está vacía, para la sucursal en uso -- Se estiver realizar a carga
		If RG5->(Eof())
			nPosEstPer := GdFieldPos("RG5_PDPERI" , aRG5Header) 
			nAuxs := Len(aAuxRG5)
			DbSelectarea("RG5")
			RG5->(DbSetOrder(1)) //RG5_FILIAL+RG5_PDPERI
			For nAux := 1 To nAuxs
				cEstper := Padr(Upper(AllTrim(aAuxRG5[ nAux, nPosEstPer ])),TamSX3("RG5_PDPERI")[1])
				
				RecLock("RG5", IIf(RG5->(MsSeek(cFilRG5 + cEstper)), .F., .T.), .T.)

				For nX := 1 To Len(aRG5Header)
					cCampo := Upper(aRG5Header[nX, 2])
					nFieldPos := RG5->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRG5Header[nX, 2] == "RG5_FILIAL")
							uCnt := cFilRG5
						Else
							nPosField := GdFieldPos(cCampo , aRG5Header)
							uCnt := aAuxRG5[nAux , nPosField]
						Endif
						RG5->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RG5->(MsUnlock())

			Next nAux
		EndIf

		//Verifica si la tabla Detalle Estándar de Periodos está vacía para la sucursal en uso.
		If RG6->(Eof())
			nPosEstPed := GdFieldPos("RG6_PDPERI" , aRG6Header) 
			nPosEstCod := GdFieldPos("RG6_CODIGO" , aRG6Header) 
			nPosEstNum := GdFieldPos("RG6_NUMPAG" , aRG6Header) 
			nAuxsRG6 := Len(aAux)
			DbSelectarea("RG6")
			RG6->(DbSetOrder(1)) //RG6_FILIAL+RG6_PDPERI+RG6_CODIGO+RG6_NUMPAG
			For nAuxRG6 := 1 To nAuxsRG6
				cEstped := Padr(Upper(AllTrim(aAux[ nAuxRG6, nPosEstPed ])),TamSX3("RG6_PDPERI")[1])
				cEstped += Padr(Upper(AllTrim(aAux[ nAuxRG6, nPosEstCod ])),TamSX3("RG6_CODIGO")[1])
				cEstped += Padr(Upper(AllTrim(aAux[ nAuxRG6, nPosEstNum ])),TamSX3("RG6_NUMPAG")[1])

				RecLock("RG6", IIf(RG6->(MsSeek(cFilRG6 + cEstped)), .F., .T.), .T.)

				For nX := 1 To Len(aRG6Header)
					cCampo := Upper(aRG6Header[nX, 2])
					nFieldPos := RG6->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRG6Header[nX, 2] == "RG6_FILIAL")
							uCnt := cFilRG6
						Else
							nPosField := GdFieldPos(cCampo , aRG6Header)
							uCnt := aAux[nAuxRG6 , nPosField]
						Endif
						RG6->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RG6->(MsUnlock())
			Next nAuxRG6
		EndIf
	EndIf

	RestArea(aAreaRG5)
	RestArea(aAreaRG6)
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} GpexCrgRG9
	Función utilizada para arga los Registros de la Tabla de 
	Criterios de Acumulación (RG9) a partir de conceptos por proceso.

	@type  Function
	@author marco.rivera
	@since 28/09/2022
	@version 1.0
	@example
	GpexCrgRG9()
	/*/
Function GpexCrgRG9()

	Local aArea		:= GetArea()
	Local aAreaRG9	:= RG9->(GetArea()) 
	Local aAux		:= {}
	Local aRG9Header:= {}
	Local bFunc		:= {|| NIL}
	Local cCampo	:= ""
	Local cFilRG9	:= xFilial("RG9")
	Local cAusent	:= ""
	Local cFunRG9	:= ("GPRG9" + cPaisLoc)
	Local nFieldPos
	Local nPosField
	Local nPosAusent
	Local nAux
	Local nAuxs
	Local nX
	Local uCnt
	Local cFiltro := 'RG9->RG9_FILIAL == "' + cFilRG9 + '"' 
	Local bFiltro := { || &(cFiltro) }

	//Valida que exista la función del país actual
	If FindFunction(cFunRG9)
		bFunc := __ExecMacro("{ ||  " + cFunRG9 + "( @aAux , @aRG9Header ) }")
		Eval(bFunc)
		DbSelectarea("RG9")
		RG9->(DbSetOrder(1)) //RG9_FILIAL+ RG9_CODCRI
		RG9->(DbSetfilter( bFiltro, cFiltro ))
		RG9->(DbGoTop())
		
		//Verifica si la tabla de Criterios de Acumulación está vacía para la sucursal en uso.
		If RG9->(Eof())
			nPosAusent := GdFieldPos("RG9_CODCRI" , aRG9Header) 
			nAuxs := Len(aAux)
			DbSelectarea("RG9")
			RG9->(DbSetOrder(1)) //RG9_FILIAL+ RG9_CODCRI
			For nAux := 1 To nAuxs
				cAusent := Padr(Upper(AllTrim(aAux[ nAux, nPosAusent ])),TamSX3("RG9_CODCRI")[1])

				RecLock("RG9", IIf(RG9->(DBSeek(cFilRG9 + cAusent)), .F., .T.), .T.)

				For nX := 1 To Len(aRG9Header)
					cCampo := Upper(aRG9Header[nX, 2])
					nFieldPos := RG9->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRG9Header[nX, 2] == "RG9_FILIAL")
							uCnt := cFilRG9
						Else
							nPosField := GdFieldPos(cCampo , aRG9Header)
							uCnt := aAux[nAux , nPosField]
						Endif
						RG9->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RG9->(MsUnlock())
			Next nAux
		EndIf
	EndIf

	RestArea(aAreaRG9)
	RestArea(aArea)
	
Return Nil

/*/{Protheus.doc} GpexRCMMI

	Función utilizada para ejecutar las funciones que generan los PRX de MI,
	correspondientes al Estandar de los Conceptos del Sistema.
	Los archivos generados dependerán del país. GPRCM + cPaisLoc + .prx

	@type  Function
	@author Leonel Castillo
	@since 04/10/2022
	@version 1.0
	@example
	GpexRCMMI()
	/*/
Function GpexGerRCM(cPath, aListaArch)

	Local aIniHdrRCM						// Cabecalho da tabela RCM com os campos
	Local aRCMVirtual						// Campos virtuais de RCM
	Local aLinesProg 	:= {}				// Array com as linhas dos programas
	Local aLinesFunc 	:= {}			 	// Array com as linhas das funcoes dos itens RCM

	Local cProg								// string a ser enviado ao arquivo PRX
	Local cTexto							// valor do campo do Header
	Local cValueCampo						// montagem da string a ser enviado ao array

	Local nUsado							// Campos utilizados
	Local nArq								// Situacao do arquivo
	Local nX
	Local nY

	Local cNomArch1		 := ""

	Default cPath		 := "" //Ruta donde se guardan los archivos
	Default aListaArch	 := {} //Lista de archivos generados anteriormente

	cArquivo 	:= ("GPRCM" + cPaisLoc + ".PRX")
	cNomArch1   := cArquivo

	aIniHdrRCM	:= RCM->( GdMontaHeader( @nUsado, @aRCMVirtual, NIL, NIL, NIL, .T.,.T.,,,,,,,.F. ) )
	Begin Sequence  // MOSTRA DRIVES   MOSTRA HARD DISK RETORNA DIRETORIO

	cArquivo := cPath + cArquivo

	If File(cArquivo)
		If !(MsgYesNo(STR0026 + cNomArch1 + STR0027 + cArquivo, + STR0028)) //"¡El archivo " - " ya existe!, ¿Desea sobreescribir? " - "¡Atención!"
			Break
		EndIf
	EndIf

	nArq := MSFCREATE(cArquivo, 0)
	IF Ferror() # 0 .And. nArq = -1
		cMsg := OemToAnsi(STR0029) + STR(Ferror(),3) //"Error en la grabación del archivo - Código DOS: "
		MsgInfo(cMsg, OemToAnsi(STR0009)) //"Atención"
		Return(.F.)
	Endif

	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Cabecalho da funcao                                          ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	aAdd(aLinesProg, '#INCLUDE "PROTHEUS.CH"' + CRLF + CRLF)
	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³Fun??o    ³GPRCM" + cPaisLoc + "      " + "³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Descri??o ³Verbas padroes                                              ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Sintaxe   ³                                                            ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³Parametros³<Vide Parametros Formais>                                   ³" + CRLF)
	aAdd(aLinesProg, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesProg, "³ Uso      ³Generico                                                    ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, "Function GPRCM" + cPaisLoc + "( aAusent, aRCMHeader )" + CRLF)
	aAdd(aLinesProg, "Local nPosAusent 	:= 0" + CRLF)
	aAdd(aLinesProg, 'Local lRet	  		:= .T.' + CRLF + CRLF)

	aAdd(aLinesProg, "DEFAULT aAusent 		:= {}" + CRLF)
	aAdd(aLinesProg, "DEFAULT aRCMHeader	:= {}" + CRLF + CRLF)

	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Cabecalho de RCM                                           ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)

	For nX := 1 To Len(aIniHdrRCM)
		cProg      := ""
		For nY := 1 To Len(aIniHdrRCM[nX])
			cTexto := If(ValType(aIniHdrRCM[nX,nY]) == "N", AllTrim(Str(aIniHdrRCM[nX,nY])),;
						   	If(ValType(aIniHdrRCM[nX,nY])=="L", Transform(aIniHdrRCM[nX, nY],"@!"),;
						   	   aIniHdrRCM[nX, nY]))
			cTexto := StrTran(cTexto, "'", '"')
			cProg += "'" + cTexto + "'"
			If nY < Len(aIniHdrRCM[nX])
				cProg += ","
			EndIf

		Next nY

		If !Empty(cProg)
			cTela := AllTrim(GetSx3Cache( aIniHdrRCM[nX][2], "X3_TELA" ))
			If !Empty(cTela)
				aAdd(aLinesProg, "IF( MV_MODFOL = '" + cTela + "', aAdd(aRCMHeader, " + '{ ' + cProg + ' })' + ", '')" + CRLF)
			Else
				aAdd(aLinesProg, "aAdd(aRCMHeader, " + '{ ' + cProg + ' })' + CRLF)
            Endif
		EndIf
	Next nX

	aAdd(aLinesProg, CRLF)

	aAdd(aLinesProg, "/*/" + CRLF)
	aAdd(aLinesProg, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesProg, "³ Validar a Estrutura das Tabela RCM                           ³" + CRLF)
	aAdd(aLinesProg, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesProg, 'lRet := fNewOldSx3(aRCMHeader, NIL, "RCM", NIL, .F.)' + CRLF + CRLF)

	aAdd(aLinesProg, 'If lRet' + CRLF)

	// Gera a chamada para a funcao //
	cNameFunc :=  'ItensAusent (aAusent)'
	aAdd(aLinesProg, '		' + cNameFunc + CRLF)

	aAdd(aLinesFunc, "/*/" + CRLF)
	aAdd(aLinesFunc, "ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿" + CRLF)
	aAdd(aLinesFunc, "³Fun??o    ³"+cNameFunc + "³Autor³ Gerado pelo sistema ³ Data ³" + Substr(DtoS(date()),7,2)+"/"+Substr(DtoS(date()),5,2)+"/"+Substr(DtoS(date()),1,4) + "³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³Descri??o ³Tipos Ausent padroes da tabela RCM                                      ³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³Sintaxe   ³                                                                   ³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³Parametros³<Vide Parametros Formais>                                          ³" + CRLF)
	aAdd(aLinesFunc, "ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´" + CRLF)
	aAdd(aLinesFunc, "³ Uso      ³Generico                                                           ³" + CRLF)
	aAdd(aLinesFunc, "ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/" + CRLF)
	aAdd(aLinesFunc, "Static Function " + cNameFunc + CRLF + CRLF)

	aAdd(aLinesFunc, "DEFAULT aAusent := {}" + CRLF + CRLF)

	//ITENS DAS TIPOS AUSENTISMOS
	RCM->(( RetOrdem( "RCM" , "RCM_FILIAL+RCM_TIPO" ) ) )
	RCM->(dbGoTop())
	While RCM->( !Eof() )

		cProg := "aAdd(aAusent, { "

		For nX := 1 To Len(aIniHdrRCM)
			cValueCampo := ""

			If aIniHdrRCM[nX,8] == "N"
				cValueCampo += AllTrim(Str(RCM->(&(aIniHdrRCM[nX,2]))))
			ElseIf "FILIAL" $ aIniHdrRCM[nX,2]
				cValueCampo += ""
			Else
				cValueCampo += AllTrim(RCM->(&(aIniHdrRCM[nX,2])))
			EndIf
			cValueCampo := StrTran(cValueCampo, "'", '"')

			If (aIniHdrRCM[nX,8] != "N") .and. (aIniHdrRCM[nX,8] != "D") .and. (aIniHdrRCM[nX,8] != "L")
				cValueCampo := "'" + cValueCampo
				cValueCampo += "'"
			EndIf

			cProg += cValueCampo
			If nX < Len(aIniHdrRCM)
				cProg += ","
			EndIf
		Next nX
		cProg += "} )"
		
		aAdd(aLinesFunc, cProg + CRLF)

		RCM->(dbSkip())

	Enddo
	aAdd(aLinesFunc, CRLF)
	aAdd(aLinesFunc, 'Return( NIL )')

	aAdd(aLinesProg, CRLF)
	aAdd(aLinesProg, 'EndIf' + CRLF + CRLF)
	aAdd(aLinesProg, 'Return( NIL )' + CRLF + CRLF)

	//TRANSFERIR AS LINHAS PARA DENTRO DO PROGRAMA
	For nX := 1 To Len(aLinesProg)
		Fwrite( nArq, aLinesProg[nX] )
	Next nX
	For nX := 1 To Len(aLinesFunc)
		Fwrite( nArq, aLinesFunc[nX] )
	Next nX

	FClose(nArq)

	aAdd(aListaArch, cNomArch1)

End Sequence

Return NIL

/*/{Protheus.doc} GpexCrgRCM

Carga los Registros de la Tabla de Tipos de Ausentimos RCM a partir de conceptos

@author Leonel Castillo
@since 26/09/2022
@version 1.0
@example
GpexCrgRCM()
/*/
Function GpexCrgRCM()

	Local aArea		:= GetArea()
	Local aAreaRCM	:= RCM->(GetArea()) 
	Local aAux		:= {}
	Local aRCMHeader:= {}
	Local bFunc		:= {|| NIL}
	Local cCampo	:= ""
	Local cFilRCM	:= xFilial("RCM")
	Local cAusent	:= ""
	Local cFunRCM	:= ("GPRCM" + cPaisLoc)
	Local nFieldPos
	Local nPosField
	Local nPosAusent
	Local nAux
	Local nAuxs
	Local nX
	Local uCnt
	Local cFiltro := 'RCM->RCM_FILIAL == "' + cFilRCM + '"' 
	Local bFiltro := { || &(cFiltro) }

	// Verifica a Existencia da Funcao do Pais Corrente
	If FindFunction(cFunRCM)
		bFunc := __ExecMacro("{ ||  " + cFunRCM + "( @aAux , @aRCMHeader ) }")
		Eval(bFunc)
		DbSelectarea("RCM")
		RCM->(DbSetOrder(1)) ////RCM_FILIAL+RCM_TIPO
		RCM->(DbSetfilter( bFiltro, cFiltro ))
		RCM->(DbGoTop())
			
		//Verifica se Tabela de Tipos de Ausentismos esta Vazia, para a filial em uso -- Se estiver realizar a carga
		If RCM->(Eof())
			nPosAusent := GdFieldPos("RCM_TIPO" , aRCMHeader) 
			nAuxs := Len(aAux)
			DbSelectarea("RCM")
			RCM->(DbSetOrder(1)) //RCM_FILIAL+RCM_TIPO
			For nAux := 1 To nAuxs
				cAusent := Padr(Upper(AllTrim(aAux[ nAux, nPosAusent ])),TamSX3("RCM_TIPO")[1])
				RecLock("RCM",IIf(RCM->(MsSeek(cFilRCM + cAusent)),.F.,.T.),.T.)
				For nX := 1 To Len(aRCMHeader)
					cCampo := Upper(aRCMHeader[nX, 2])
					nFieldPos := RCM->(FieldPos(cCampo))
					If (nFieldPos > 0)
						If (aRCMHeader[nX, 2] == "RCM_FILIAL")
							uCnt := cFilRCM
						Else
							nPosField := GdFieldPos(cCampo , aRCMHeader)
							uCnt := aAux[nAux , nPosField]
						Endif
						RCM->(FieldPut(nFieldPos , uCnt))
					EndIF
				Next nX
				RCM->(MsUnlock())

			Next nAux
		EndIf
	EndIf

	RestArea(aAreaRCM)
	RestArea(aArea)

Return NIL

/*/{Protheus.doc} GPXGrvCV0
	
	Función utilizada para la grabación del empleado como entidad contable (CV0).

	@type  Function
	@author marco.rivera
	@since 23/12/2022
	@version 1.0
	@param nOperacion, Numérico, Operación a realizar (2 - Visualización / 3 - Inclusión / 4 - Alteracion / 5 - Exclusión / 7 - Copia)
	@param cCodigoId, Código de la identificación (RA_RG) antes del grabado.
	@example
	GPXGrvCV0(nOperacion, cCodigoId)
	/*/
Function GPXGrvCV0(nOperacion, cCodigoId)

	Local aAreaSRA		:= SRA->(GetArea())
	Local lAltEntCV0	:= SuperGetMV("MV_ALTCV0", .F., .F.) //Parámetro que indica si se altera Archivo de Entidades (CV0)
	Local cTipoDoc		:= ""
	Local cCodCert		:= ""
	Local cCodIdEmp		:= ""
	Local cNomCompl		:= ""
	Local dFecAdmEmp	:= dDataBase
	Local cTabTmpCV0	:= GetNextAlias()
	Local cFilCV0		:= xFilial("CV0")
	Local cNumItem		:= ""
	Local lExistCV0		:= .F.
	Local nRegRecno		:= 0

	Default nOperacion	:= 3
	Default cCodigoId	:= ""

	If lAltEntCV0 //Si el parámetro está habilitado para alterar CV0

		cCodIdEmp	:= RTrim(M->RA_RG)
		cTipoDoc 	:= IIf(Empty(M->RA_TPCIC), "NI", AllTrim(M->RA_TPCIC))
		cNomCompl	:= RTrim(M->RA_NOMECMP)
		dFecAdmEmp	:= M->RA_ADMISSA

		//Se obtiene el Tipo de Documento del Colaborador y asigna código para el Certificado
		cCodCert := fDescRCC("S022", cTipoDoc, 1, 2, 38, 2)
		
		If nOperacion == 3 .Or. nOperacion == 7 //Si es Inclusión o Copia de un empleado

			//Valida que el registro no exista en la tabla CV0
			BeginSql Alias cTabTmpCV0
				SELECT COUNT(CV0_CODIGO) AS NUMREGS 
				FROM %table:CV0% CV0 
				WHERE CV0.CV0_FILIAL = %exp:cFilCV0% AND
				CV0.CV0_CODIGO = %exp:cCodIdEmp% AND
				CV0.%NotDel%
			EndSql

			DBSelectArea(cTabTmpCV0)
			(cTabTmpCV0)->(DBGoTop())

			lExistCV0 := (cTabTmpCV0)->NUMREGS > 0

			(cTabTmpCV0)->(DBCloseArea())

			If !lExistCV0 //Si no existe registro en CV0

				//Se obtene el consecutivo de la tabla CV0
				BeginSql Alias cTabTmpCV0
					SELECT MAX(CV0_ITEM) AS ITEM 
					FROM %table:CV0% CV0 
					WHERE CV0.CV0_FILIAL = %exp:cFilCV0% AND
					CV0.%NotDel%
				EndSql

				DBSelectArea(cTabTmpCV0)
				(cTabTmpCV0)->(DBGoTop())

				//Define el consecutivo del movimiento a insertar
				cNumItem := IIf(Val((cTabTmpCV0)->ITEM) > 0, Soma1((cTabTmpCV0)->ITEM), Soma1(StrZero(0,TamSX3("CV0_ITEM")[1])))

				(cTabTmpCV0)->(DBCloseArea())

				//Se realiza grabación en CV0
				RecLock("CV0", .T.)
				CV0->CV0_FILIAL	:= cFilCV0 //Filial de la tabla CV0
				CV0->CV0_PLANO	:= "01" //Valor default para empleados
				CV0->CV0_ITEM	:= cNumItem //Consecutivo del ítem a insertar
				CV0->CV0_CODIGO	:= cCodIdEmp //Número de identificación
				CV0->CV0_DESC	:= cNomCompl //Nombre completo del empleado
				CV0->CV0_CLASSE	:= "2" //Valor default para empleados
				CV0->CV0_NORMAL	:= "2" //Valor default para empleados
				CV0->CV0_ENTSUP	:= "22" //Valor default para empleados
				CV0->CV0_DTIEXI	:= dFecAdmEmp //Fecha de Adminisión del empleado
				If CV0->(ColumnPos("CV0_TIPO00")) > 0
					CV0->CV0_TIPO00	:= "03" //Tipo 03 - Empleados
				EndIf
				If CV0->(ColumnPos("CV0_TIPO01")) > 0
					CV0->CV0_TIPO01	:= cCodCert //Código del certificado
				EndIf
				If CV0->(ColumnPos("CV0_COD")) > 0
					CV0->CV0_COD	:= cCodIdEmp //Número de identificación
				EndIf
				If CV0->(ColumnPos("CV0_LOJA")) > 0
					CV0->CV0_LOJA	:= "01" //Valor default para empleados
				EndIf
				CV0->(MsUnLock())

			EndIf

		ElseIf nOperacion == 4 //Si es modificación
			
			//Obtiene registro de la CV0
			BeginSql Alias cTabTmpCV0
				SELECT R_E_C_N_O_ AS RECNO
				FROM %table:CV0% CV0 
				WHERE CV0.CV0_FILIAL = %exp:cFilCV0% AND
				CV0.CV0_CODIGO = %exp:cCodigoId% AND
				CV0.%NotDel%
			EndSql

			DBSelectArea(cTabTmpCV0)
			(cTabTmpCV0)->(DBGoTop())

			nRegRecno := (cTabTmpCV0)->RECNO

			(cTabTmpCV0)->(DBCloseArea())

			If nRegRecno > 0 //Si existe el registro
				DBSelectArea("CV0")
				CV0->(DBSetOrder(2)) //CV0_FILIAL+CV0_CODIGO
				CV0->(DBGoTo(nRegRecno))

				//Se realiza actualización en CV0
				RecLock("CV0", .F.)
				CV0->CV0_CODIGO	:= cCodIdEmp //Número de identificación
				CV0->CV0_DESC	:= cNomCompl //Nombre completo del empleado
				CV0->CV0_DTIEXI	:= dFecAdmEmp //Fecha de Adminisión del empleado
				If CV0->(ColumnPos("CV0_TIPO01")) > 0
					CV0->CV0_TIPO01	:= cCodCert //Código del certificado
				EndIf
				If CV0->(ColumnPos("CV0_COD")) > 0
					CV0->CV0_COD	:= cCodIdEmp //Número de identificación
				EndIf
				CV0->(MsUnLock())
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSRA)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GrvSRFArg	ºAutor  ³Alejandro Parrales	 º Data ³  09/05/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Funcion que actualiza registros de la tabla SRF           º±±
±±º          ³  para Argentina                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GrvSRFArg(cVerbFer, dDateIni, cTpRoteir, cMat, dAdmissa, cCodconv, nAniosMax, dFecFinPer)
	
	Local aAreaSRF		:= SRF->(GetArea())
	Local aAreaRGM		:= RGM->(GetArea())
	Local aArea			:= GetArea()
	Local nAnosTrab  	:= 0
	Local cCodTab    	:= ""
	Local nPosTab    	:= 0
	Local nDiasFer    	:= 0
	Local lAchou     	:= .F.
	Local lFerias    	:= (cTpRoteir == "3") //Valida el procedimiento de calculo
	Local cAliasTrb		:= ""
	Local nDiasProp		:= 0
	Local cNueAnio		:= ""
	Local cFilialSRF    := xFilial("SRF")
    Local cFilialRGM    := xFilial("RGM")
    Local cQuery        := ""
    Local oStatement    := NIL

	Default cVerbFer   	:= ""
	Default dDateIni	:= CtoD("")
	Default cMat		:= ""
	Default dAdmissa	:= CtoD("")
	Default cCodconv	:= ""
	Default nAniosMax	:= 0 //Años de vigencia de vacaciones
	Default dFecFinPer	:= CtoD("")

	//Posiciona el registro de la tabla control dias derecho
	dbSelectArea("SRF")
	SRF->(DbSetOrder(2)) //RF_FILIAL+RF_MAT+RF_PD+DTOS(RF_DATABAS)
	SRF->(dbGoTop())
	SRF->(MsSeek(cFilialSRF+cMat+cVerbFer))
	While SRF->(!EoF()) .And. SRF->(RF_FILIAL+RF_MAT+RF_PD) == cFilialSRF+cMat+cVerbFer
		If SRF->RF_PD == cVerbFer .AND. SRF->RF_STATUS == "1" .AND. Year(dDateIni) == Year(SRF->RF_DATAFIM)
			lAchou     := .T.
			Exit
		EndIf
		SRF->( DbSkip() )
	EndDo

	If !lFerias .And. lAchou
		// Obtiene dias derecho conforme al convenio del empleado
		nAnosTrab:= Year(dDateIni) - Year(dAdmissa)
		nMesTrab := Month(dDateIni) - Month(dAdmissa) + 1
		If !Empty(cCodconv) .And. fPosReg("RGM",1,cFilialRGM+cCodconv) .And. ;
			!Empty(RGM->RGM_TABFER)
			cCodTab := RGM->RGM_TABFER
		Endif

		If !Empty(cCodTab) 
			nPosTab := fPosTab("S011", cCodTab,"=", 4, nAnosTrab,"<=", 6)		
			nDiasFer := Iif(nPosTab > 0, fTabela("S011",nPosTab,7), 0)
		EndIf
		If nAnosTrab == 0
			// Tratamiento para cuando el empleado ingresa en Enero
			If  Month(dDateIni) == 6 .and. Month(dAdmissa) == 1 
				RecLock('SRF',.F.)
				SRF->RF_DFERVAT	:= SRF->RF_DIASDIR //Dias de referencia pasan a dias vencidos
				SRF->(MsUnLock())
			//Tratamiento cuando el empleado cumpla 6 meses y cuando el empleado ingresa despues de julio
			ElseIf nMesTrab == 6 .or. (Month(dAdmissa) > 7 .and. Month(dDateIni) == 12)
				/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula dias de vacaciones proporcionales                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				nDiasProp:= Round((nDiasFer/365) * (SRF->RF_DATAFIM - dAdmissa),0)
				RecLock('SRF',.F.)
				SRF->RF_DFERAAT	:= nDiasProp //Grava el campo de días proporcionales
				SRF->(MsUnLock())
			EndIf
		//Tratamiento especial para enero
		ElseIf Month(dDateIni) == 1 .and. nAnosTrab > 0
			RecLock('SRF',.F.)
			SRF->RF_DFERVAT	:= SRF->RF_DIASDIR //Dias de referencia pasan a dias vencidos
			SRF->(MsUnLock())
		EndIf
		//Crea nuevo periodo después de septiembre
		If Month(dDateIni) >= 9 
			// Valida que el nuevo periodo no exista en la tabla SRF
            cQuery :=  "SELECT SRF.RF_MAT "
            cQuery +=  " FROM ? SRF"
            cQuery += " WHERE SRF.RF_FILIAL = ? AND "
            cQuery += " SRF.RF_PD = ? AND "
            cQuery += " SRF.RF_STATUS = '1' AND "
            cQuery += " SRF.RF_MAT = ? AND "
            cQuery += " SRF.RF_DATAFIM = ? AND "
            cQuery += " SRF.D_E_L_E_T_ = ' ' "
            
            oStatement := FwExecStatement():New(cQuery)
            oStatement:SetUnsafe(1, RetSqlName("SRF"))
            oStatement:SetString(2, cFilialSRF)
            oStatement:SetString(3, cVerbFer)
            oStatement:SetString(4, cMat)
            oStatement:SetString(5, DTOS(CTOD("31/12/"+Ltrim(Str((Year(dDateIni)+1))))))
            cAliasTrb := oStatement:OpenAlias()
            DbSelectArea(cAliasTrb)
            (cAliasTrb)->(DbGoTop())
            
            //Crea nuevo periodo
			While (cAliasTrb)->(Eof())
                cNueAnio := Ltrim(Str(Year(SRF->RF_DATABAS)+1))
				RecLock('SRF',.T.)
				SRF->RF_FILIAL 	:= cFilialSRF
				SRF->RF_MAT		:= cMat
				SRF->RF_STATUS 	:= "1"
				SRF->RF_PD		:= cVerbFer
				SRF->RF_DATABAS	:= CTOD("01/01/"+cNueAnio)
				SRF->RF_DATAFIM := CTOD("31/12/"+cNueAnio)
				SRF->RF_DIASDIR	:= nDiasFer
				SRF->RF_DFERAAT	:= 0
				SRF->RF_DIASANT	:= 0
				SRF->RF_DFERVAT	:= 0
				SRF->RF_DFERANT	:= 0
				SRF->( MsUnLock() )
                Exit
			EndDo
			(cAliasTrb)->(dbCloseArea())
            oStatement:Destroy()
            oStatement:= nil
		EndIf
	EndIf

	If nAniosMax > 0
		// Valida vigencia de registros en Programación de Vacaciones (SRF).
		SRF->(dbGoTop())
		SRF->(MsSeek(cFilialSRF+cMat+cVerbFer))
		While SRF->(!EoF()) .And. SRF->RF_FILIAL == cFilialSRF .And. SRF->RF_MAT == cMat .And. SRF->RF_PD == cVerbFer
			If SRF->RF_STATUS == "1"
				dBsLastVac := SRF->RF_DATAFIM
				dDatePresc := (YearSum(dBsLastVac, Int(nAniosMax)))
				dDatePresc := MonthSum(dDatePresc, ((nAniosMax - Int(nAniosMax)) * 12))
				If dFecFinPer >= dDatePresc
					RecLock("SRF", .F.)
					SRF->RF_STATUS := "2" //Prescrito
					SRF->(MsUnLock())
				EndIf
			EndIf
			SRF->( DbSkip() )
		EndDo
	EndIf

	RestArea(aArea)
	RestArea(aAreaSRF)
	RestArea(aAreaRGM)
Return


/*/{Protheus.doc} nomeStaticFunction
	(long_description)
	@type  Function
	@author kossoy.carolina
	@since 02/01/2025
	@version 1.0
	@return cTipo, caracter, codigo que corresponde al tipo de procedimiento 3 vacaciones
/*/

Function fGetRotVac()  
	Local cFilSRY := FWXFILIAL("SRY")
	Local cTipo:= ""	
	Local aArea:= GetArea()
		dbSelectArea("SRY")
		SRY->(dbSetOrder(1)) 
		SRY->(MsSeek(cFilSRY)) 
		While (SRY->(!EOF()) .aND. SRY->RY_FILIAL == cFilSRY)
			If SRY->RY_TIPO == "3"
				cTipo := SRY->RY_CALCULO
				Exit
			EndIF
			SRY->(DBSkip())		
		End
		RestArea(aArea)
Return cTipo

/*/{Protheus.doc} MsgAvisoMI
	Función para mostrar mensajes temporales relacionados a cambios en legislación,
	y con opción para abrir la documentación de TDN relacionada.
	@type  Function
	@author oscar.lopez
	@since 21/08/2025
	@version 1.0
	@return Nil
	@example
		MsgAvisoMI()
	/*/
Function MsgAvisoMI()

	Local cTitulo	:= STR0030	// "Aviso"
	Local cSubTitulo:= ""		// Subtítulo
	Local cMensaje	:= ""		// Mensaje
	Local nTamVenta	:= 3		// Tamaño de ventana (1-Pequeño, 2-Mediano o 3-Grande)
	Local nOpcOK	:= 0		// Opción Default botón "OK"
	Local nOpcSelec	:= 0		// Opción seleccionada
	Local aBotones	:= {}		// Arreglo de botones
	Local aUrls		:= {}		// URL correspondiente a los botones (no considera botón OK)

	If !IsBlind()
		If cPaisLoc == "COL"
			If IsInCallStack("GPEM020") .And. IsInCallStack("GPEM022")
				cSubTitulo += "Para el cumplimiento de las Reformas Laboral y Pensional de Colombia se han realizado actualizaciones al producto, "
				cSubTitulo += "si aún no ha realizado las configuraciones correspondientes a dichas normas, "
				cSubTitulo += "podrá consultar la documentación a continuación: "

				cMensaje += "Reforma Laboral:" + CRLF + CRLF
				cMensaje += "En cumplimiento de la Ley 2466 de 2025, se hace necesario implementar los ajustes correspondientes en el sistema, "
				cMensaje += "para mayor información consulte la opción: Reforma Laboral"  + CRLF + CRLF
				cMensaje += "Reforma Pensional Ley 2831:" + CRLF + CRLF
				cMensaje += "Se suspende temporalmente la aplicabilidad de la Ley 2831 / 2024, para mayor información consulte la opción: Reforma Pensional" + CRLF+ CRLF

				AAdd(aUrls, "https://tdn.totvs.com/pages/releaseview.action?pageId=954096481")
				AAdd(aUrls, "https://tdn.totvs.com/pages/releaseview.action?pageId=969971955")

				AAdd(aBotones, "Reforma Pensional")
				AAdd(aBotones, "Reforma Laboral")
			EndIf
			AAdd(aBotones, "OK") //Opción para salir de la ventana de aviso.
		EndIf

		If !Empty(cMensaje)
			// Opción default para salir de rutina (botón OK)
			nOpcOK := Len(aBotones)

			While .T.
				nOpcSelec := Aviso(cTitulo, cMensaje, aBotones, nTamVenta, cSubTitulo)
				If nOpcSelec > 0 .And. nOpcSelec < nOpcOK
					shellExecute("Open", aUrls[nOpcSelec], "", "", SW_NORMAL)
				Else
					Exit
				EndIf
			EndDo
		EndIf
	EndIf

Return Nil
