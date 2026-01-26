#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSFSMDIC
Métodos Rest do FSM
@author flavio.martins
@since 14/04/2025
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL FSMDIC DESCRIPTION "WS de Integração Field Services Manager" 
   
	WSDATA aliasTable AS STRING
	WSDATA fieldName AS STRING

	// Métodos GET
	WSMETHOD GET fieldsStruct  DESCRIPTION 'Retorna informações do dicionário de dados dos campos utilizados no FSM' PATH "fieldsStruct" PRODUCES APPLICATION_JSON 
	WSMETHOD GET nextCodeByAlias  DESCRIPTION 'Retorna próximo código de uma tabela do dicionário' PATH "nextCodeByAlias" PRODUCES APPLICATION_JSON 

END WSRESTFUL

WSMETHOD GET fieldsStruct  WSREST FSMDIC
Local lRet      := .T.
Local aTables   := {'SA1','SA2','SA3','JN0','SBM','JN1','JNZ','AA3','AA4','JNH','AAA',;
					'JN3','JN4','JN5','JN6','JO4','JNS','AA1','JNI','JNJ','JNV','JNY',;
					'JN7','JN9','JNA','JNB','SRJ','SB1','SB2','JO2','JND','JNE','JNF',;
					'JNG','JNK','JNM','JNN','JNO','JNP','JNQ','JNX','JNR','JNU','JNV',;
					'JO0','JOD','JNL','JO1','JO3','JO4','JO5','JO6','SAH','JO7','JO8',;
					'JOA','JOB','JOC','JO3','JN5'}
Local aFields 	:= {}
Local oResponse	:= JsonObject():New()
Local nFields 	:= 0
Local nX      	:= 0
Local nTable    := 0;
 
oResponse['fields'] := {}

For nTable := 1 To Len(aTables)

	nX := 0

	aFields := FWSX3Util():GetListFieldsStruct(aTables[nTable], .T.)

	For nX := 1 To Len(aFields)

		nFields++

		Aadd(oResponse['fields'], JsonObject():New())

		oResponse['fields'][nFields]['name'] 		:= aFields[nX][1]
		oResponse['fields'][nFields]['type'] 		:= aFields[nX][2]
		oResponse['fields'][nFields]['length'] 		:= aFields[nX][3]
		oResponse['fields'][nFields]['precision']	:= aFields[nX][4]
		oResponse['fields'][nFields]['mask'] 		:= AllTrim(aFields[nX][5])
		oResponse['fields'][nFields]['required']    := X3OBRIGAT(aFields[nX][1])
		
	Next

Next 

Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return lRet 

WSMETHOD GET nextCodeByAlias WSRECEIVE aliasTable, fieldName WSREST FSMDIC
Local lRet      := .T.
Local oResponse	:= JsonObject():New()
Local cNextCode := ''
Local cMsgError := ''

Default Self:aliasTable := ''
Default Self:fieldName  := ''

If Self:aliasTable == ''
	cMsgError := " Parâmetro 'aliasTable' não informado. "
	lRet := .F.
Endif

If Self:fieldName == ''
	cMsgError += " Parâmetro 'fieldName' não informado. "
	lRet := .F.
Endif

If (lRet)

	cNextCode := GetSxEnum(Self:aliasTable, Self:fieldName)

	oResponse['nextCode'] := cNextCode

	Self:SetResponse(FwJsonSerialize(oResponse, .F., .F., .T.))

	ConfirmSx8()

Else
	
    SetRestFault(400, I18N(cMsgError))

Endif

Return lRet
