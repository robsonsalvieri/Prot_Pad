#include "protheus.ch"
#include "tbiconn.ch"
#include 'msobject.ch'
#include 'MATA090S.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA090S()
schedule para importação de taxas de moeda banco méxico
@author Marcelo Hruschka
@since 24/08/2025
@version 1.0
@return NIL

Parametros da rotina
MV_TCURLBC   	Tipo caracter, Url del banco
MV_TCTOKEN		Tipo caracter, token de conexão
MV_TCDIAS 		Tipo numérico, Número de días a regresar.
MV_TCULTEX 	 	Tipo caracter, Fecha y hora de la última ejecución.
MV_TCULTMS 	 	Tipo caracter, Message de la última ejecución.
MV_TCLISMO 		Tipo caracter, Códigos de moneda que debe actualizar el Job, si esta vacio actualizara todas las que estén en el ambiente y que existAn en la API.

/*/

Function MATA090S

	// declaracao de variaveis
	Local cURL     as character
	Local cSerie   as character
	Local nDias    as numeric
	Local cToken   as character
	Local oRest    as object
	Local oJson    as object
	Local cPath    as character
	Local aHeaders as array
	Local aSerie   as array
	Local nValor   as numeric
	Local nS       as numeric
	Local nD       as numeric
	Local cMoeda   as character
	Local cRetorno as character
	Local cCampo   as character
	Local dFecha   as date

	// busca dos parametros
	cURL     := GetNewPAR("MV_TCURLBC","https://www.banxico.org.mx")
	aSerie   := &(GetNewPAR("MV_TCLISMO" ,"{{'SF43718',2},{'SF46410',4}}"))
	nDias    := GetNewPAR("MV_TCDIAS" ,10)
	cToken   := GetNewPAR("MV_TCTOKEN","")
	aHeaders := {}
	dFecha   := date()-nDias

	// valida se foi preenchido
	If Len(aSerie) <= 0
		PutMV('MV_TCULTMS',STR0001)	// "El parámetro MV_TCLISMO está definido incorrectamente, ¡verifíquelo!"
		Return
	Endif

	// define o token
	cToken := 'Bmx-Token: ' + cToken
	aAdd(aHeaders, cToken)

	// processa todas as moedas
	For nS := 1 To Len(aSerie)

		// valida se o array tem tamanho correto
		If Len(aSerie[nS]) = 2

			// processa os dias
			For nD := 1 to nDias
		
				// define moeda a buscar
				cSerie := aSerie[nS,1]
				cMoeda := cValToChar(aSerie[nS,2])

				// inicializa REST
				oRest := NIL
				oJson := jsonObject():new()
				cFecha  := DTOS(dFecha+nD)
				cPath := subStr(cFecha, 1, 4) + '-' + subStr(cFecha, 5, 2) + '-' + subStr(cFecha, 7, 2)
				cPath := '/SieAPIRest/service/v1/series/' + cSerie + '/datos/' + cPath + '/' + cPath
				oRest := fwRest():new(cURL)
				oRest:setPath(cPath)

				If oRest:get(aHeaders)

					oJson:FromJson(oRest:getResult())

					If !oJson['bmx']['series'][1]:hasProperty('datos')
						Loop
					Else
						nValor := oJson['bmx']['series'][1]['datos'][1]['dato']
					Endif

					// atualiza sempre na data d+1
					cFechAtu := DTOS(DataValida(STOD(cFecha)+1,.T.))

					// cria ou atualiza o registro na SM2
					dbSelectArea('SM2')
					SM2->(dbSetOrder(1)) 	// M2_DATA
					If !SM2->(dbSeek(cFechAtu))
						RecLock('SM2', .T.)
						SM2->M2_DATA := sToD(cFechAtu)
					Else
						RecLock('SM2', .F.)
					Endif

					// atualiza o campo de moeda
					cCampo := "M2_MOEDA" + cMoeda
					If SM2->(ColumnPos(cCampo)) > 0
						FieldPut(ColumnPos(cCampo),val(nValor))
					Endif	
					SM2->M2_INFORM := 'S'
					SM2->(MsUnlock())
					cRetorno := STR0002 // "¡Actualizado con éxito!" # " - Serie: " # " Moneda: "	

				Else

					cResult  := oRest:GetResult()
					cRetorno := "Error"
					oJson    := JsonObject():New()
					rJson    := oJson:FromJson(cResult)
					If ValType(rJson) <> "C" .And. "detalle" $ cResult .And. "url" $ cResult

						// formata mensagem e retorna
						cMessage := oJson["error"]["detalle"]
						cMessage += " "
						cMessage += oJson["error"]["url"]
						If Type('cMessage') <> 'U'
							cRetorno := DecodeUTF8(cMessage)
						Endif

					Endif

				Endif

				// fecha objetos
				oJson := NIL
				oRest := NIL

			Next

		Endif

	Next

	//Guarda la fecha de ejecución.
	PutMv('MV_TCULTEX',DTOC(date())+" "+TIME())
	PutMV('MV_TCULTMS',cRetorno)

Return

/*/{Protheus.doc} SchedDef
    Función requerida para definir el grupo de preguntas 
    en los parámetros del Schedule.
    /*/
Static Function SchedDef()
	Local aParam  := {}

	aParam := { "P",;			//Tipo R para relatorio P para processo
	"",;			//Pergunte do relatorio, caso nao use passar ParamDef
	,;				//Alias
	,;				//Array de ordens
	"MATA090S",;  	//Titulo
	"MATA090S",;  	//Nome
	.F.,;           // PERMITE agendamento sempre ativo
	.F.}	        // PERMITE agendamento por filiais

Return aParam
