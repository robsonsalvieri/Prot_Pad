#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR2099.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR4099
Função que gera um evento de fechamento do período apuração do evento R-4099
V3W_SITPER( 0=Fechamento; 1=Reabertura )
Premissa: Sempre existir apenas um V3W_ATIVO = '1' e D_E_L_E_T_ = ' '

@param cEvento, caracter, Nome do evento a ser processado
@param cPeriodo, caracter, periodo a ser processado MMAAAA
@param cIdLog, caracter, ID de processamento da apuração

@return Nil
@author José Mauro / Denis Souza
@since  23/09/2019 
@modifield 26/09/2022
@version 1.1
/*/
//---------------------------------------------------------------------
Function TAFAPR4099( cEvento, cPeriodo , cIdLog, aFiliais, lSucesso )

Local cReturn 	As Character
Local cKeyProc	As character
Local cKeyC1E	As character
Local cAmbReinf	As character
Local cVerReinf As character
Local cTpPer    As character
Local oModel 	As object
Local nMatriz	As numeric
Local aContato 	As array
Local lSeekV3W	As logical

Default cEvento  := ''
Default cPeriodo := ''
Default cIdLog	 := ''
Default aFiliais := {}
Default lSucesso := .F.

cReturn	  := ''
cKeyProc  := ''
cKeyC1E	  := ''
cAmbReinf := Left( GetNewPar( "MV_TAFAMBR", "2" ), 1 )
cVerReinf := StrTran( SuperGetMv('MV_TAFVLRE', .F., '1_04_00' ), '_', '' )
cTpPer    := '0' //0=fechamento;1=reabertura
oModel	  := Nil
nMatriz	  := aScan(aFiliais,{|x| x[07] })
aContato  := {}
lSeekV3W  := .F.

If GetFechamento( cEvento, cIdLog, cPeriodo, @cReturn )

	DBSelectArea("V3W")
	V3W->( DBSetOrder(2) ) //V3W_FILIAL, V3W_PERAPU, V3W_ATIVO, R_E_C_N_O_, D_E_L_E_T_
	If V3W->( DBSeek(xFilial("V3W") + cPeriodo + "1") )
		cKeyProc := V3W->V3W_FILIAL + V3W->V3W_ID + V3W->V3W_VERSAO
		lSeekV3W := .T.
	EndIf
	oModel  := FWLoadModel( "TAFA548" )

	If lSeekV3W
		If V3W->V3W_EVENTO == 'I' .And. V3W->V3W_STATUS $ ( ' 013' )
			cTpPer := iif( V3W->V3W_SITPER == '0','0','1' ) //aqui deverá ficar igual
			lDelete := .T.
		Elseif V3W->V3W_STATUS == '4'
			cTpPer := iif( V3W->V3W_SITPER == '0','1','0' ) //aqui deverá ficar invertido antes do FAltRegAnt
			FAltRegAnt( 'V3W','2', .F. ) //inativar anterior
			lDelete := .F.
		Endif
		if lDelete
			oModel:SetOperation(MODEL_OPERATION_DELETE)
			oModel:Activate()
			FwFormCommit( oModel )
			oModel:DeActivate()
			cTpPer := iif(V3W->V3W_SITPER == '0','0','1') //aqui deverá ficar igual, após Delecao Inserir novo registro
		endif    
	endif

	cKeyC1E	 := xFilial("C1E") + aFiliais[nMatriz][02] + "1"
	aContato := TafRetCTT("C1E", cKeyC1E, 3, "R" ) //C1E_FILIAL, C1E_FILTAF, C1E_ATIVO, R_E_C_N_O_, D_E_L_E_T_

	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	oModel:LoadValue('MODEL_V3W', "V3W_ID"	  , TAFGERAID("TAF") )
	oModel:LoadValue('MODEL_V3W', "V3W_VERSAO", xFunGetVer() )
	oModel:LoadValue('MODEL_V3W', "V3W_PERAPU", cPeriodo )
	oModel:LoadValue('MODEL_V3W', "V3W_VERANT", "" )
	oModel:LoadValue('MODEL_V3W', "V3W_PROTPN", "" )
	oModel:LoadValue('MODEL_V3W', "V3W_EVENTO", "I" ) //Sera sempre inclusao nao havera retificacao e nem exclusao
	oModel:LoadValue('MODEL_V3W', "V3W_ATIVO" , "1" )
	oModel:LoadValue('MODEL_V3W', "V3W_STATUS", "0" )
	oModel:LoadValue('MODEL_V3W', "V3W_TPAMB" , cAmbReinf )
	oModel:LoadValue('MODEL_V3W', "V3W_NMRESP", Substr(aContato[02],1,TamSx3("V3W_NMRESP")[1] ) )
	oModel:LoadValue('MODEL_V3W', "V3W_CPFRES", Substr(aContato[03],1,TamSx3("V3W_CPFRES")[1] ) )
	oModel:LoadValue('MODEL_V3W', "V3W_DDDFON", Alltrim(Substr(aContato[04],1,TamSx3("V3W_DDDFON")[1] ) ) )
	oModel:LoadValue('MODEL_V3W', "V3W_FONE"  , Alltrim(Substr(aContato[05],1,TamSx3("V3W_FONE")[1] ) ) )
	oModel:LoadValue('MODEL_V3W', "V3W_EMAIL" , Substr(aContato[01],1,TamSx3("V3W_EMAIL")[1] ) )
	oModel:LoadValue('MODEL_V3W', "V3W_SITPER", cTpPer )

	If !oModel:VldData()
		lSucesso := .F.
		cReturn += TafRetEMsg( oModel )
		TafXLog( cIdLog, cEvento, "ERRO", STR0005 + CRLF + cReturn ) //"Mensagem do erro: "
	Else
		lSucesso := .T.
		FwFormCommit( oModel )

		cReturn += STR0004+CRLF+STR0010+cPeriodo+iif(cTpPer=='0',STR0011,STR0012)+STR0013 //"Registro Gravado com sucesso."##"Período "##" fechado "##" reaberto "##"com sucesso."
		TafEndGRV( "V3W", "V3W_PROCID", cIdLog, V3W->(Recno()))
		//Para Log na V0K concatena o recno.
		TafXLog(cIdLog,cEvento,"MSG",cReturn + CRLF + STR0014 + cValToChar( V3W->(Recno()) ),cPeriodo) //"Recno: "
	EndIf
	oModel:DeActivate()

EndIf

Return( cReturn )

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFechamento()

Retorna se existe Reabertura transmitido para haver o fechamento 
Importante: V1O_NOMEVE = R4099F Fechamento; R4099R Reabertura
@param 

@Author		José Mauro / Denis Souza
@since  	23/09/2019 
@modifield 	26/09/2022
@Version	1.0
/*/
//---------------------------------------------------------------------
Static Function GetFechamento( cEvento, cIdLog, cPeriodo, cReturn )

Local lRet := .T.

Default cPeriodo := StrTran(cPeriodo,"/","")
Default cReturn  := ""

//Se existir reabertura transmitido ou nenhuma reabertura, verifica se não tem nenhum fechamento em aberto
DBSelectArea("V3W")
V3W->( DBSetOrder(2) ) //V3W_FILIAL, V3W_PERAPU, V3W_ATIVO, R_E_C_N_O_, D_E_L_E_T_
If V3W->( DBSeek( xFilial("V3W") + cPeriodo + "1") )
	If V3W->V3W_STATUS == '2'
		lRet := .F.
		cReturn += STR0015 + iif(V3W->V3W_SITPER=="0",STR0016,STR0017) + STR0018 //"Já existe "##"um fechamento transmitido"##"uma reabertura transmitida"##" aguardando retorno."
		TafXLog( cIdLog, cEvento, "ALERTA", cReturn, cPeriodo )
	Endif
EndIf

Return lRet
