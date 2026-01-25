#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR2099.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2099
Função que efetua chamada da rotina de apuração do evento R-2099 

@param cEvento, caracter, Nome do evento a ser processado
@param cPeriodo, caracter, periodo a ser processado MMAAAA
@param cIdLog, caracter, ID de processamento da apuração

@return Nil

@author Karen Honda
@since  28/03/2018
@version 1.1
/*/
//---------------------------------------------------------------------
Function TAFAPR2099( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lJob )
	Local cReturn as character	
	Local lProc     as logical

	default lJob := .f.

	lProc 	:= oProcess <> nil
	cReturn	:= ""
	If lProc
		oProcess:IncRegua2("")
	EndIf

	cReturn := TAFR2099( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lJob ) 	

Return( cReturn )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR2099
Função que gera um evento de fechamento do período
Premissas: deve existir um evento de 2099- Fechamento, transmitido e validado 

@return Nil

@author Karen Honda
@since 19/02/2018
@version 1.1
/*/
//---------------------------------------------------------------------
Static Function TAFR2099( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lJob )

Local cId			as character
Local cKeyProc		as character
Local cVerReg		as character
Local cVerAnt		as character
Local cVerAtu		as character
Local cProtAnt		as character
Local oModel 		as object
Local lSeekV0B		as logical 
Local cPerMsg		as character
Local cStat2010		as character
Local cStat2020		as character
Local cStat2030		as character
Local cStat2040		as character
Local cStat2050		as character
Local cStat2055		as character
Local cStat2060		as character
Local cStat2070		as character
Local cSemMovto		as character
Local cMovtoAnt		as character		
Local cReturn		as character
Local nMatriz		as numeric
Local nlA			as numeric
Local nAte			as numeric
Local cKeyC1E		as character
Local aContato 		as array
Local cAmbReinf		as character
Local cVerReinf 	as character
Local cComMvt		as character
Local cPerAM    	as character
Local cErro			as character
Local lExecuta		as logical
Local lGrava		as logical
Local lReinf15		as logical

cVerReinf	:= StrTran( SuperGetMv('MV_TAFVLRE',.F.,'1_04_00') ,'_','')
nMatriz		:= aScan(aFiliais,{|x| x[07] })
nlA			:= 1
nAte        := 0
cPerMsg 	:= SubStr(cPeriodo,1,2) + "/" + SubStr(cPeriodo,3,4)
cReturn		:= ""
cErro		:= ""
cKeyC1E		:= ""
cMovtoAnt	:= ""
aContato 	:= {}
cAmbReinf	:= Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
cPerAM		:= right(cPeriodo,4)+left(cPeriodo,2) //Periodo no formato AAAAMM
lExecuta	:= .t.
lGrava		:= .t.
cStat2055	:= '2'
lReinf15	:= alltrim(cVerReinf) >= "10500" .and. TAFColumnPos('V0B_AQUIRU')

DBSelectArea("V1O")
V1O->(DBSetOrder(2)) // V1O_FILIAL, V1O_PERAPU, V1O_ATIVO,V1O_BLOCO R_E_C_N_O_, D_E_L_E_T_
If !V1O->( DbSeek( xFilial("V1O") + cPeriodo + "1" + "20" ) )
	Taf503Grv("", cPeriodo,Date(), Time(), "", "20")
EndIf

If GetFechamento(cEvento,cIdLog,cPeriodo,lJob)
	If !lJob 
		lExecuta := MsgYesNO( STR0001 + cPerMsg + "?", "R-2099") //"Deseja realmente fechar o período " 
	endif

	if lExecuta
	
		DBSelectArea("V0B")
		DBSetOrder(2) //V0B_FILIAL, V0B_PERAPU, V0B_ATIVO, R_E_C_N_O_, D_E_L_E_T_
		If V0B->(DBSeek( xFilial("V0B") + cPeriodo + "1"))
			cKeyProc 	:= V0B->V0B_FILIAL + V0B->V0B_ID + V0B->V0B_VERSAO 
			lSeekV0B := .T.
		EndIf	
		oModel := FWLoadModel("TAFA496")
	
		cVerAnt		:= ""
		cVerAtu		:= ""
		cProtAnt	:= ""
		lGrava		:= .T.
		cID			:= ""
		cStat2010		:= ""
		cStat2020		:= ""
		cStat2030		:= ""
		cStat2040		:= ""
		cStat2050		:= ""
		cStat2060		:= ""
		cStat2070		:= ""
		cSemMovto		:= ""
		cXmlId			:= ""
	
		If lSeekV0B
			// Desativa o registro anterior
			If V0B->V0B_STATUS == "4" 
				cVerAnt	:= V0B->V0B_VERSAO
				cProtAnt:= V0B->V0B_PROTUL
				cId := V0B->V0B_ID
				cMovtoAnt:= V0B->V0B_COMMVT
				FAltRegAnt( 'V0B', '2', .F. )
				
			// Evento transmitido e aguardando retorno, nao permite gravar
			ElseIf V0B->V0B_STATUS $ '2|6'
				lGrava	:= .F.
			Else
				// Apaga o Registro
				cVerAnt	:= V0B->V0B_VERANT
				cProtAnt:= V0B->V0B_PROTPN
				cId     := V0B->V0B_ID
				cMovtoAnt:= V0B->V0B_COMMVT
				cXmlId	:= V0B->V0B_XMLID
						
				oModel:SetOperation(MODEL_OPERATION_DELETE)
				oModel:Activate()
				FwFormCommit( oModel )
				oModel:DeActivate()
			EndIf
		EndIf
	
		If lGrava
			aFiliais := aClone(TafXRFils( aFiliais , 2))
			If FindFunction("TafEvRStat")
				TafEvRStat( aFiliais, cPeriodo, "R-2010", @cStat2010  ) 
				TafEvRStat( aFiliais, cPeriodo, "R-2020", @cStat2020  )
				TafEvRStat( aFiliais, cPeriodo, "R-2030", @cStat2030  )
				TafEvRStat( aFiliais, cPeriodo, "R-2040", @cStat2040  )
				TafEvRStat( aFiliais, cPeriodo, "R-2050", @cStat2050  )
				if lReinf15; TafEvRStat( aFiliais, cPeriodo, "R-2055", @cStat2055  ); endif // R-2055 evtAquis
				TafEvRStat( aFiliais, cPeriodo, "R-2060", @cStat2060  )
				
				cStat2010 := IIf( cStat2010  $ "4|6", "1", "2" )
				cStat2020 := IIf( cStat2020  $ "4|6", "1", "2" )
				cStat2030 := IIf( cStat2030  $ "4|6", "1", "2" )
				cStat2040 := IIf( cStat2040  $ "4|6", "1", "2" )
				cStat2050 := IIf( cStat2050  $ "4|6", "1", "2" )
				if lReinf15; cStat2055 := IIf( cStat2055  $ "4|6", "1", "2" ); endif // R-2055 evtAquis
				cStat2060 := IIf( cStat2060  $ "4|6", "1", "2" )
			Else
				cStat2010		:= If(TafRStatEv( cPeriodo,  , ,"R-2010", aFiliais  ) == "5", "2", "1" )
				cStat2020		:= If(TafRStatEv( cPeriodo,  , ,"R-2020", aFiliais  ) == "5", "2", "1" )
				cStat2030		:= If(TafRStatEv( cPeriodo,  , ,"R-2030", aFiliais  ) == "5", "2", "1" )
				cStat2040		:= If(TafRStatEv( cPeriodo,  , ,"R-2040", aFiliais  ) == "5", "2", "1" )
				cStat2050		:= If(TafRStatEv( cPeriodo,  , ,"R-2050", aFiliais  ) == "5", "2", "1" )
				if lReinf15; cStat2055	:= If(TafRStatEv( cPeriodo,  , ,"R-2055", aFiliais  ) == "5", "2", "1" ); endif	// R-2055 evtAquis
				cStat2060		:= If(TafRStatEv( cPeriodo,  , ,"R-2060", aFiliais  ) == "5", "2", "1" )
			EndIf

			If cStat2010 == "2" .and. cStat2020 == "2" .and. cStat2030 == "2" .and. cStat2040 == "2" .and.;
			   cStat2050 == "2" .and. cStat2055 == "2" .and. cStat2060 == "2"
			   //Informar a primeira competência a partir da qual não houve movimento, cuja situação perdura até a competência atual.
			   cSemMovto		:= SubStr(cPeriodo,3,4)+"-" + SubStr(cPeriodo,1,2)
			EndIf 
			
			//---- Sempre será uma inclusão
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()
			
			cVerReg := IIf( Empty(cVerAtu),xFunGetVer(),cVerAtu)

			oModel:LoadValue('MODEL_V0B', "V0B_ID", Iif(Empty(cID), TAFGERAID("TAF") ,cID) )
			oModel:LoadValue('MODEL_V0B', "V0B_VERSAO"	, cVerReg )
			oModel:LoadValue('MODEL_V0B', "V0B_PERAPU"	, cPeriodo )
			oModel:LoadValue('MODEL_V0B', "V0B_VERANT"	, AllTrim(cVerAnt))
			oModel:LoadValue('MODEL_V0B', "V0B_PROTPN"	, AllTrim(cProtAnt))
			oModel:LoadValue('MODEL_V0B', "V0B_EVENTO"	, "I" )
			oModel:LoadValue('MODEL_V0B', "V0B_ATIVO "	, "1" )
			oModel:LoadValue('MODEL_V0B', "V0B_STATUS "	, "0" )
			
			oModel:LoadValue('MODEL_V0B', "V0B_SERTOM"	, cStat2010 )
			oModel:LoadValue('MODEL_V0B', "V0B_SERPRE"	, cStat2020 )
			oModel:LoadValue('MODEL_V0B', "V0B_ASSDES"	, cStat2030 )
			oModel:LoadValue('MODEL_V0B', "V0B_ASSREP"	, cStat2040 )
			oModel:LoadValue('MODEL_V0B', "V0B_COMPRO"	, cStat2050 )
			if lReinf15; oModel:LoadValue('MODEL_V0B', "V0B_AQUIRU"	, cStat2055 ); endif // R-2055 evtAquis
			oModel:LoadValue('MODEL_V0B', "V0B_CPRB"	, cStat2060 )
			oModel:LoadValue('MODEL_V0B', "V0B_PGTOS"	, cStat2070 )

			if cVerReinf < '10400' .Or. cPerAM <= "201810"
				cComMvt := If(!Empty(cMovtoAnt) .and. !Empty(cSemMovto),cMovtoAnt, cSemMovto)
			else	
				cComMvt := ''
			endif
			oModel:LoadValue('MODEL_V0B', "V0B_COMMVT"	, cComMvt )			

			If FindFunction("TafRetCTT")
				cKeyC1E		:= xFilial("C1E")+aFiliais[nMatriz][02]+"1"
				aContato 	:= TafRetCTT("C1E", cKeyC1E, 5, "R" )
				nAte := len( aContato )
				for nlA := 1 to nAte
					if valtype( aContato[nlA] ) == 'U'
						aContato[nlA] := ''
					endif
				next nlA
				oModel:LoadValue('MODEL_V0B', "V0B_NOMCNT"	, Substr(aContato[02],1,TamSx3("V0B_NOMCNT")[1] ) )
				oModel:LoadValue('MODEL_V0B', "V0B_CPFCNT"	, Substr(aContato[03],1,TamSx3("V0B_CPFCNT")[1] ) )
				oModel:LoadValue('MODEL_V0B', "V0B_DDDFON"	, Alltrim(Substr(aContato[04],1,TamSx3("V0B_DDDFON")[1] ) ) )
				oModel:LoadValue('MODEL_V0B', "V0B_FONCNT"	, Alltrim(Substr(aContato[05],1,TamSx3("V0B_FONCNT")[1] ) ) )
				oModel:LoadValue('MODEL_V0B', "V0B_EMAIL"	, Substr(aContato[01],1,TamSx3("V0B_EMAIL")[1] ) )

			Else
				DBSelectArea("C1E")
				C1E->( DBSetOrder(3) )
				If C1E->( MSSeek( xFilial("C1E") + cFilAnt + "1" ) )
					oModel:LoadValue('MODEL_V0B', "V0B_NOMCNT"	, Substr(C1E->C1E_NOMCNT,1,TamSx3("V0B_NOMCNT")[1] ) )
					oModel:LoadValue('MODEL_V0B', "V0B_CPFCNT"	, Substr(C1E->C1E_CPFCNT,1,TamSx3("V0B_CPFCNT")[1] ) )
					oModel:LoadValue('MODEL_V0B', "V0B_DDDFON"	, Alltrim(Substr(C1E->C1E_DDDFON,1,TamSx3("V0B_DDDFON")[1] ) ) )
					oModel:LoadValue('MODEL_V0B', "V0B_FONCNT"	, Alltrim(Substr(C1E->C1E_FONCNT,1,TamSx3("V0B_FONCNT")[1] ) ) )
					oModel:LoadValue('MODEL_V0B', "V0B_EMAIL"	, Substr(C1E->C1E_EMAIL,1,TamSx3("V0B_EMAIL")[1] ) )
				EndIf
			EndIf
			
			// Campo que armazena o ambiente gerado para transmissão
			If TafColumnPos("V0B_TPAMB")
				oModel:LoadValue('MODEL_V0B', "V0B_TPAMB", cAmbReinf ) 
			EndIf	

			DBSelectArea("V0B")			
						
			If oModel:VldData() 
				FwFormCommit( oModel )
				//grava _PROCID
				TafEndGRV( "V0B","V0B_PROCID", cIdLog, V0B->(Recno()))
				if !lJob
					MsgAlert( STR0002 + cPerMsg + STR0003)	//"Período " " fechado!"
				endif
				TafXLog( cIdLog, cEvento, "MSG"			, STR0004+CRLF+"Período "+cPeriodo+" fechado com sucesso."+CRLF+"Recno => "+cValToChar(V0B->(Recno())),cPeriodo )	//"Registro Gravado com sucesso."					
			Else
				cErro := TafRetEMsg( oModel )
				TafXLog( cIdLog, cEvento, "ERRO"			, STR0005 + CRLF + cErro, cPeriodo )	//"Mensagem do erro: "					
			EndIf
	
			oModel:DeActivate()					
					
		Else
			TafXLog( cIdLog, cEvento, "ALERTA"			, STR0006+CRLF+ cKeyProc , cPeriodo)	//"Evento transmitido e aguardando retorno:"									
		EndIf
	Else
		TafXLog( cIdLog, cEvento, "ALERTA"			, "Fechamento cancelado pelo usuário!" , cPeriodo )
		cReturn := "Cancelado pelo usuário!"
	EndIF

	if !lGrava	
		cReturn += "Evento transmitido e aguardando retorno, nao permite gravar"
	endif	

	if !empty(cErro)	
		cReturn += cErro
	endif

EndIf
Return( cReturn )


//---------------------------------------------------------------------
/*/{Protheus.doc} GetFechamento()

Retorna se existe o 2098 - Reabertura transmitido para haver o fechamento 
@param 

@Author		Karen Honda
@Since		28/03/2018
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GetFechamento(cEvento,cIdLog,cPeriodo,lJob)
Local lRet := .T. 
cPeriodo 	:= StrTran(cPeriodo,"/","")
DBSelectArea("V1O")
DBSetOrder(2) //V1O_FILIAL, V1O_PERAPU, V1O_ATIVO, R_E_C_N_O_, D_E_L_E_T_
If V1O->(DBSeek( xFilial("V1O") + cPeriodo + "1"+"20"))
	If (V1O->V1O_STATUS == "4" .and. V1O->V1O_NOMEVE == "R-2098") .or. Empty(V1O->V1O_NOMEVE) 
		lRet := .T.
	Else	
		lRet := .F.
		if !lJob
			MsgAlert(STR0007+CRLF+ STR0008) //"Período não está em aberto para haver o fechamento." "Fechamento de período não realizado!"
		endif
		TafXLog( cIdLog, cEvento, "ALERTA"			, STR0007+CRLF+ STR0008, cPeriodo  )
	EndIf
Else	
	lRet := .T.
EndIf	
If lRet // se existe reabertura transmitido ou nenhuma reabertura, verifica se não tem nenhum fechamento em aberto
	DBSelectArea("V0B")
	DBSetOrder(2) //V0B_FILIAL, V0B_PERAPU, V0B_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	If V0B->(DBSeek( xFilial("V0B") + cPeriodo + "1"))
		If V0B->V0B_STATUS == "2" 
			lRet := .F.
			if !lJob
				MsgAlert(STR0009+CRLF+ V0B->(V0B_FILIAL + V0B_ID ) + ". "+ STR0008) //"Já existe um evento de fechamento R-2099 em aberto:""Fechamento de período não realizado!"
			endif
			TafXLog( cIdLog, cEvento, "ALERTA"			, STR0009+CRLF+ V0B->(V0B_FILIAL + V0B_ID , cPeriodo)  )
	   	Endif
	EndIf
EndIf

Return lRet
