//BIBLIOTECAS
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

//CONSTANTES
#DEFINE PRX_LIN CHR(13) + CHR(10)

	
/*/{Protheus.doc} DSVFAT1
	Ejecución de Transmisión electrónica via CHEDULE/JOB.
	@type function
	@author eduardo.manriquez
	@since 12/11/2024
	@version 1

	@param cSfpEsp, caracter, Parámetro que contiene las especies expresado en SQL para consulta tabla SFP
	@param aSerNfe, caracter, Parámetro que contiene las series expresado en SQL para consulta tabla SFP

	@return ${return}, ${return_description}
	@example
	DSVFAT1(cSfpEsp,cSerVld)
	@see (links_or_references)
/*/
Function DSVFAT1(cSfpEsp,cSerVld)
	
	Local cAliTmp	:= GetNextAlias()
	Local nI		:= 0
	Local nCriArq 	:= 0
	Local lDirExi	:= .F.							
	Local cSelectQry := ""
	Local cFromQry   := ""
	Local cWhereQry  := ""
	Local aLogTrans  := {}
	Local aLogEnv    := {}
	Local cAutSer    := ""
	Local cAutNtI    := ""
	Local cAutNtF    := ""
	Local cNomArq    := ""
	Local cDirLog    := GetSrvProfString("StartPath", "\undefined") + "Transmision_Auto_Log\" 
	Default cSfpEsp  := ""
	Default cSerVld  := ""
		
	If( ! ExistDir( cDirLog ) )
		lDirExi := MakeDir( cDirLog )
	EndIf

	aAdd( aLogEnv, { "LOG", "**Linha-0110", DtoS( Date() ) + "|" + Time() } )

	cSelectQry := "% SFP.FP_SERIE, SFP.FP_NUMINI, SFP.FP_NUMFIM, SFP.FP_ESPECIE, SFP.FP_PV, "
	cSelectQry += " SFP.FP_FILUSO, SFP.FP_FILIAL, SFP.R_E_C_N_O_ RECNO %"
	cFromQry   := "% " + RetSqlName('SFP') + " SFP %"
	cWhereQry  := "% SFP.FP_FILIAL = '" + xFilial('SFP') + "'"
	cWhereQry  += " AND "+ cSfpEsp 
	cWhereQry  += " AND "+ cSerVld
	cWhereQry  += " AND SFP.D_E_L_E_T_ = '' %"

	BeginSql Alias cAliTmp
		SELECT %exp:cSelectQry%
		FROM  %exp:cFromQry%
		WHERE %exp:cWhereQry%
		ORDER BY %Order:SFP,6%
	EndSql

	(cAliTmp)->( DbGoTop() )
	cMsg := "-*-*----------------TRANSMISIÓN DE DOCUMENTOS FISCALES POR JOB----------------*-*-"+ CRLF
	aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )
	While( (cAliTmp)->( ! Eof() ) )
		cAutSer		:= (cAliTmp)->FP_SERIE              
		cAutNtI		:= (cAliTmp)->FP_NUMINI
		If( ! Empty( (cAliTmp)->FP_NUMFIM ) )    
			cAutNtF	:= (cAliTmp)->FP_NUMFIM    
		Else
			cAutNtF	:= (cAliTmp)->FP_NUMINI
		EndIf
		
		
		If( (cAliTmp)->FP_ESPECIE $ "1" )		/// ROTINA PARA TRANSMISSÃO DE REMITO    
			aLogTrans := LxTraCOL("SF2","NF",cAutSer,cAutNtI,cAutNtF,.T.)
			cMsg:= "-*-*----------------Facturas de salida----------------*-*-" + CRLF
			cMsg+= "- Serie-[" + cAutSer + "] - Num_Ini-[" + cAutNtI + "] - Num_Fim-[" + cAutNtF + "]" 

			aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )

			PrepLogJOB(aLogTrans,@aLogEnv)
			//Documento Soporte
			aLogTrans := LxTraCOL("SF1","NF",cAutSer,cAutNtI,cAutNtF,.T.)
			cMsg:= "-*-*----------------Documento Soporte----------------*-*-" + CRLF
			cMsg+= "- Serie-[" + cAutSer + "] - Num_Ini-[" + cAutNtI + "] - Num_Fim-[" + cAutNtF + "]" 
			aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )

			PrepLogJOB(aLogTrans,@aLogEnv)
		Elseif ( (cAliTmp)->FP_ESPECIE $ "2" ) // Nota de Crédito
			aLogTrans := LxTraCOL("SF1","NCC",cAutSer,cAutNtI,cAutNtF,.T.)
			cMsg:= "-*-*----------------Notas de Crédito Cliente----------------*-*-" + CRLF
			cMsg+= "- Serie-[" + cAutSer + "] - Num_Ini-[" + cAutNtI + "] - Num_Fim-[" + cAutNtF + "]" 

			aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )

			PrepLogJOB(aLogTrans,@aLogEnv)
		Elseif ( (cAliTmp)->FP_ESPECIE $ "3" ) // Nota de Débito
			aLogTrans := LxTraCOL("SF2","NDC",cAutSer,cAutNtI,cAutNtF,.T.)
			cMsg:= "-*-*----------------Notas de Débito Cliente----------------*-*-" + CRLF
			cMsg+= "- Serie-[" + cAutSer + "] - Num_Ini-[" + cAutNtI + "] - Num_Fim-[" + cAutNtF + "]" 
			
			aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )
			
			PrepLogJOB(aLogTrans,@aLogEnv)
		Elseif ( (cAliTmp)->FP_ESPECIE $ "8" ) // Nota de Crédito Ajuste
			aLogTrans := LxTraCOL("SF2","NCP",cAutSer,cAutNtI,cAutNtF,.T.)
			cMsg:= "-*-*----------------Notas de Crédito Ajuste----------------*-*-" + CRLF
			cMsg+= "- Serie-[" + cAutSer + "] - Num_Ini-[" + cAutNtI + "] - Num_Fim-[" + cAutNtF + "]" 
			
			aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )
			
			PrepLogJOB(aLogTrans,@aLogEnv)
		Elseif ( (cAliTmp)->FP_ESPECIE $ "9" ) // Nota de Débito Ajuste
			aLogTrans := LxTraCOL("SF1","NDP",cAutSer,cAutNtI,cAutNtF,.T.)
			cMsg:= "-*-*----------------Notas de Débito Ajuste----------------*-*-" + CRLF
			cMsg+= "- Serie-[" + cAutSer + "] - Num_Ini-[" + cAutNtI + "] - Num_Fim-[" + cAutNtF + "]" 
			
			aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )
			
			PrepLogJOB(aLogTrans,@aLogEnv)
		EndIf
		(cAliTmp)->( DbSkip() )
	End

	(cAliTmp)->( DbCloseArea() )
	cNomArq := "LOG_" + DtoS( Date() ) + "_" + StrTran( Time(), ":", "" ) + ".txt"
	cDirLog += cNomArq
	nCriArq := FCREATE( cDirLog )

	If( nCriArq = -1 )
		Conout("Error al crear el archivo LOG" + Str(Ferror()))
	Else
		cAutRet := ""
		For nI := 1 To Len( aLogEnv )
			cAutRet += aLogEnv[nI][1] + "||" + aLogEnv[nI][3] + CRLF
		Next
	
		FWrite( nCriArq, cAutRet + CRLF )
		FClose( nCriArq )
	EndIf			

Return 


/*/{Protheus.doc} PrepLogJOB
	Preparación de Array para generación de log del proceso
	@type Function
	@author eduardo.manriquez
	@since 09/11/2024
	@version 1.0
	@param aLogTrans, Array , arreglo que contiene los mensajes de proceso de transmisión de documentos
	@param aLogEnv, Array , arreglo que guarda los mensajes para generar el log
	@example
	PrepLogJOB(aLogTrans,aLogEnv)
/*/
Function PrepLogJOB(aLogTrans,aLogEnv)
	Local nX := 0
	Local nY := 0
	Local cTitulos   := "Documento       Serie    Cliente  Tienda  Detalle" + CRLF
	Local cMsg   := ""
	Default aLogTrans := {}
	Default aLogEnv := {}

	If Len(aLogTrans) > 1
		cMsg += cTitulos
	Endif

	For nX:=1 To Len(aLogTrans)
		For nY:= 1 To Len(aLogTrans[nX])
			cMsg += aLogTrans[nX][nY] + CRLF
		Next nY
	Next nX
	aAdd( aLogEnv, { cMsg, "**", DtoS( Date() ) + "|" + Time() } )
Return 
