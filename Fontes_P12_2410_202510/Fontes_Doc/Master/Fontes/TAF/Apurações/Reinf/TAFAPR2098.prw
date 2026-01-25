#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR2098.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2098
Função que efetua chamada da rotina de apuração do evento R-2098 

@param cEvento, caracter, Nome do evento a ser processado
@param cPeriodo, caracter, periodo a ser processado MMAAAA
@param cIdLog, caracter, ID de processamento da apuração

@return Nil

@author Karen Honda
@since  28/03/2018
@version 1.1
/*/
//---------------------------------------------------------------------
Function TAFAPR2098( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lJob )
Local cReturn	:= ''
default lJob	:= .f.

	cReturn := TAFR2098( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lJob ) 	

Return (cReturn)

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFR2098
Função que gera um evento de reabertura do período
Premissas: deve existir um evento de 2099- Fechamento, transmitido e validado 

@return Nil

@author Karen Honda
@since 19/02/2018
@version 1.1
/*/
//---------------------------------------------------------------------
Static Function TAFR2098( cEvento, cPeriodo , dDtIni, dDtFim, cIdLog, aFiliais, oProcess, lJob )

Local cId			as character
Local cKeyProc		as character
Local cVerReg		as character
Local cVerAnt		as character
Local cProtAnt		as character
Local cReturn		as character
Local cErro			as character
Local oModel 		as object
Local lSeekV1A		as logical
local lExecuta		as logical
local lGrava		as logical 
Local cPerMsg		as character

cPerMsg := SubStr(cPeriodo,1,2) + "/" + SubStr(cPeriodo,3,4)
lExecuta	:=	.t.
lGrava		:=	.t.
cReturn		:=	''
cErro		:=	''

If !lJob
 	lExecuta := MsgYesNO( STR0001 + cPerMsg + "?", "R-2098") //"Deseja realmente reabrir o período "
Else
	lExecuta	:= .t.
EndIf 

if lExecuta
	DBSelectArea("V1A")
	DBSetOrder(2) //V1A_FILIAL, V1A_PERAPU, V1A_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	If V1A->(DBSeek( xFilial("V1A") + cPeriodo + "1"))
		cKeyProc 	:= V1A->V1A_FILIAL + V1A->V1A_ID + V1A->V1A_VERSAO 
		lSeekV1A := .T.
	EndIf	
	oModel := FWLoadModel("TAFA502")

	cVerAnt		:= ""
	cProtAnt	:= ""
	lGrava		:= .T.
	cID			:= ""

	If lSeekV1A
		// Desativa o registro anterior
		If V1A->V1A_STATUS == "4"
			cVerAnt	:= V1A->V1A_VERSAO
			cProtAnt:= V1A->V1A_PROTUL
			cId := V1A->V1A_ID
			FAltRegAnt( 'V1A', '2', .F. )
			
		// Evento transmitido e aguardando retorno, nao permite gravar
		ElseIf V1A->V1A_STATUS $ '2|6'
			lGrava	:= .F.
		Else
			// Apaga o Registro
			cVerAnt	:= V1A->V1A_VERANT
			cProtAnt:= V1A->V1A_PROTPN
			cId     := V1A->V1A_ID
					
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			oModel:Activate()
			FwFormCommit( oModel )
			oModel:DeActivate()
		EndIf
	EndIf

	If lGrava
		
		//---- Sempre será uma inclusão
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		
		cVerReg := xFunGetVer()
		oModel:LoadValue('MODEL_V1A', "V1A_ID", Iif(Empty(cID), TAFGERAID("TAF"),cID) )
		oModel:LoadValue('MODEL_V1A', "V1A_VERSAO"	, cVerReg )
		oModel:LoadValue('MODEL_V1A', "V1A_PERAPU"	, cPeriodo )
		oModel:LoadValue('MODEL_V1A', "V1A_VERANT"	, AllTrim(cVerAnt))
		oModel:LoadValue('MODEL_V1A', "V1A_PROTPN"	, AllTrim(cProtAnt))
		oModel:LoadValue('MODEL_V1A', "V1A_EVENTO"	, "I" )
		oModel:LoadValue('MODEL_V1A', "V1A_ATIVO "	, "1" )
		oModel:LoadValue('MODEL_V1A', "V1A_STATUS "	, "0" )			
					
		If oModel:VldData() // FwFormCommit( oModel )
			FwFormCommit( oModel )
			//oModel:CommitData()
			//criar campo PROCID?
			TafEndGRV( "V1A","V1A_PROCID", cIdLog, V1A->(Recno()))
			MsgAlert( STR0002 + cPerMsg + STR0003)	//"Período " " reaberto!"
			TafXLog( cIdLog, cEvento, "MSG"			, STR0004+CRLF+"Recno => "+cValToChar(V1A->(Recno())), cPeriodo )	//"Registro Gravado com sucesso."					
		Else
			cErro := TafRetEMsg( oModel )
			TafXLog( cIdLog, cEvento, "ERRO"			, STR0005 + CRLF + cErro, cPeriodo )	//"Mensagem do erro: "					
		EndIf

		oModel:DeActivate()					
				
	Else
	 	TafXLog( cIdLog, cEvento, "ALERTA"			, STR0006+CRLF+ cKeyProc, cPeriodo )	//"Evento transmitido e aguardando retorno:"									
	EndIf
EndIf

if !lGrava	
	cReturn += "Evento transmitido e aguardando retorno, não permite gravar"
endif	

if !empty(cErro)	
	cReturn += cErro
endif

Return (cReturn)