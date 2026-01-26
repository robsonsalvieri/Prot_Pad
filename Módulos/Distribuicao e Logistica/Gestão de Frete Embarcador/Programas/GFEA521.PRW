#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GFEA521.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA521



@since 05/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA521(lParam)
	Local dData
	Private nQtdAgend	:= 0 
	Private cResumo  	:= ""
	Private GFEResult	:= GFEViewProc():New()

	If !GFECheckGX4()
		Return .F.
	EndIF

	If !GFEA510COMP()
		MsgStop( "Necessário aplicar o update U_GFE11I20 para utilizar o processo de pátios e portarias." )
		Return .F.
	EndIf
	
	dData := Substring(DTOS(DDATABASE),1,6)
	dData += "01"    

	dbSelectArea("GVL")
	GVL->( dbSetOrder(1) )
	GVL->( dbSeek(xFilial("GVL")) )
	While !GVL->( Eof() ) .And. xFilial("GVL") == GVL->GVL_FILIAL
		If GVL_SIT != "2"	// Somente "Recorrencias Agendamento" diferente de "Inativo"  	1=Ativo    2=Inativo 
			If GVL->GVL_PERIOD == "1"
				If !Empty(GVL->GVL_DIA1)
					GRAVAGWV(VAL(GVL->GVL_DIA1),GVL->GVL_HR1)
				EndIf

				If !Empty(GVL->GVL_DIA2)
					GRAVAGWV(VAL(GVL->GVL_DIA2),GVL->GVL_HR2)
				EndIf
					
				If !Empty(GVL->GVL_DIA3)
					GRAVAGWV(VAL(GVL->GVL_DIA3),GVL->GVL_HR3)			
				EndIf
		
				If !Empty(GVL->GVL_DIA4)		  
					GRAVAGWV(VAL(GVL->GVL_DIA4),GVL->GVL_HR4)
				EndIf
				
				If !Empty(GVL->GVL_DIA5)		
					GRAVAGWV(VAL(GVL->GVL_DIA5),GVL->GVL_HR5)			
				EndIf                    
			ElseIf GVL->GVL_PERIODO == "2"    		
				dbSelectArea("GUW") 
				GUW->( dbSetOrder(1) )
		    	GUW->( dbSeek(xFilial("GUW")+dData) )       
		    	While !GUW->( Eof() ) .And. xFilial("GUW") == GUW->GUW_FILIAL .And. ;
		    			MESEXTENSO(GUW->GUW_DATA) == MESEXTENSO(DDATABASE) .And. ;
		    			YEAR(GUW->GUW_DATA) == YEAR(DDATABASE)
	
					// GUW_TPDIA 1=Util  2=Nao Util 
					If GUW->GUW_TPDIA == "1"
					
			    		If Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0001) //"Segunda"
					    	If GVL->GVL_IDSEG == "1"
			    				GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRSEG)		    			
							EndIf
					 	ElseIF Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0002) //"Terca"
				   		    If GVL->GVL_IDTER == "1"
		   						GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRTER)
						    EndIf                     
					    ElseIF Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0003) //"Quarta"
				   		    If GVL->GVL_IDQUA == "1"
		   						GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRQUA)
						    EndIf                                         
					    ElseIF Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0004) //"Quinta"
				   		    If GVL->GVL_IDQUI == "1"
		   						GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRQUI)
						    EndIf                                         
					    ElseIF Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0005) //"Sexta"
				   		    If GVL->GVL_IDSEX == "1"
		   						GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRSEX)
						    EndIf                                        
		   	    		ElseIF Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0006) //"Sabado"
				   		    If GVL->GVL_IDSAB == "1"
		   						GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRSAB)
						    EndIf                                         
		  	    		ElseIF Upper(Alltrim(GUW->GUW_DSDNU)) == Upper(STR0007) //"Domingo"
				   		    If GVL->GVL_IDDOM == "1"
			    				GRAVAGWV(DAY(GUW->GUW_DATA),GVL->GVL_HRDOM)		    			
						    EndIf		    	    			    				
						EndIf
					EndIf
	
					GUW->( dbSkip() )
				EndDo	    	
			EndIf
		EndIf

		GVL->( dbSkip() )
	EndDo


	If nQtdAgend > 0
		GFEResult:Add("Total de agendamentos gerados: "+ AllTrim( Str(nQtdAgend) ) + CRLF + cResumo)
		
       If !GFEResult:EmptyMsg()
       	GFEResult:Show("Processamento de Recorrências","Agendamentos gerados com sucesso.")
		EndIf
	Else
		MsgStop("Não foram gerados Agendamentos.","Atenção")
	EndIf

Return .T.

Static Function GRAVAGWV(dData,cHora)    
	Local cDia
	Local cNovaData
	Local cNrAgen := ""

	cDia := STRZERO(dData,2)
	
	cNovaData := Substring(DTOS(DDATABASE),1,6)
	cNovaData += cDia

	// Não processa Agendamento caso dia não válido. EXEMPLO: se dia for 35 ou 50 etc 
	If AllTrim( StrTran(DTOS( StoD(cNovaData) ) ,"/","") ) != ""

		dbSelectArea("GWV")
		GWV->( dbSetOrder(5) )
		If !GWV->( dbSeek(xFilial("GWV")+GVL->GVL_CDEMIT+cNovaData+cHora) )
			cNrAgen := GETSXENUM("GWV","GWV_NRAGEN")

			RecLock("GWV",.T.)
			GWV->GWV_FILIAL := xFilial("GWV")
			GWV->GWV_NRAGEN := cNrAgen
			GWV->GWV_CDOPER := GVL->GVL_CDOPER
			GWV->GWV_SEQ    := GVL->GVL_SEQ
			GWV->GWV_CDEMIT := GVL->GVL_CDEMIT
			GWV->GWV_TPEMIT := GVL->GVL_TPEMIT
			GWV->GWV_SIT    := "1"
			GWV->GWV_IDTIPO := "2"
			GWV->GWV_DTAGEN := STOD(cNovaData)
			GWV->GWV_HRAGEN := cHora
			GWV->GWV_IDENVI := "2"
			GWV->GWV_IDCONF := "2"
			GWV->GWV_USUCRI := cUserName
			GWV->GWV_DTCRIA := DDATABASE
			GWV->GWV_HRCRIA := TIME()
			MsUnLock("GWV")
			
			ConfirmSx8()
	
			// Grava registros no MEMO
			nQtdAgend++
			
			cResumo += "---------------------------------"+ CRLF
			cResumo += "Nr Agendamento: "+ cNrAgen + CRLF
			cResumo += "Operação: "+ GVL->GVL_CDOPER + CRLF
			cResumo += "Data: "+ dToc(STOD(cNovaData)) +"  Hora: "+ Transform(cHora,"@R 99:99") + CRLF
			cResumo += "Emitente: "+ Posicione("GU3",1,xFilial("GU3") + GVL->GVL_CDEMIT,"GU3_NMEMIT") + CRLF
		EndIf
	EndIf
	
Return .T.        
 