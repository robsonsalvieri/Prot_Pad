#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//Define constantes para utilizar nos arrays.
//Em outros fontes, utilizar a função A131APICnt para recuperar o valor das constantes.
//Ao criar novas constantes, adicionar na função A131APICnt
#DEFINE ARRAY_CALENDAR_POS_FILIAL 1
#DEFINE ARRAY_CALENDAR_POS_CODE   2
#DEFINE ARRAY_CALENDAR_POS_CALEND 3
#DEFINE ARRAY_CALENDAR_POS_DATA   4
#DEFINE ARRAY_CALENDAR_POS_HRAINI 5
#DEFINE ARRAY_CALENDAR_POS_HRAFIM 6
#DEFINE ARRAY_CALENDAR_POS_INTER  7
#DEFINE ARRAY_CALENDAR_SIZE       7

Static _lMrpInSMQ := FWAliasInDic("SMQ", .F.) .And. Findfunction("mrpInSMQ")

/*/{Protheus.doc} A131APICnt
Recupera o valor das constantes utilizadas para auxiliar na montagem do array do calendário para integração.
@type  Function
@author marcelo.neumann
@since 23/07/2019
@version P12
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function A131APICnt(cInfo)
	Local nValue := ARRAY_CALENDAR_SIZE

	Do Case
		Case cInfo == "ARRAY_CALENDAR_POS_FILIAL"
			nValue := ARRAY_CALENDAR_POS_FILIAL
		Case cInfo == "ARRAY_CALENDAR_POS_CODE"
			nValue := ARRAY_CALENDAR_POS_CODE
		Case cInfo == "ARRAY_CALENDAR_POS_CALEND"
			nValue := ARRAY_CALENDAR_POS_CALEND
		Case cInfo == "ARRAY_CALENDAR_POS_DATA"
			nValue := ARRAY_CALENDAR_POS_DATA
		Case cInfo == "ARRAY_CALENDAR_POS_HRAINI"
			nValue := ARRAY_CALENDAR_POS_HRAINI
		Case cInfo == "ARRAY_CALENDAR_POS_HRAFIM"
			nValue := ARRAY_CALENDAR_POS_HRAFIM
		Case cInfo == "ARRAY_CALENDAR_POS_INTER"
			nValue := ARRAY_CALENDAR_POS_INTER
		Case cInfo == "ARRAY_CALENDAR_SIZE"
			nValue := ARRAY_CALENDAR_SIZE
		Otherwise
			nValue := ARRAY_CALENDAR_SIZE
	EndCase

Return nValue

/*/{Protheus.doc} PCPA131API
Eventos de integração do Cadastro de Calendário do MRP
@author marcelo.neumann
@since 23/07/2019
@version P12
/*/
CLASS PCPA131API FROM FWModelEvent

	DATA lIntegraMRP    AS LOGIC
	DATA lIntegraOnline AS LOGIC

	METHOD New() CONSTRUCTOR
	METHOD InTTS(oModel, cModelId)

ENDCLASS

/*/{Protheus.doc} New
Método construtor do evento de integração das integrações do cadastro de Calendário.
@author marcelo.neumann
@since 23/07/2019
@version P12
/*/
METHOD New() CLASS PCPA131API

	::lIntegraOnline := .F.
	::lIntegraMRP    := IntNewMRP("MRPCALENDAR", @::lIntegraOnline)

Return Self

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.
@author marcelo.neumann
@since 23/07/2019
@version P12
@param oModel  , Object  , Modelo principal
@param cModelId, Caracter, Id do submodelo
@return Nil
/*/
METHOD InTTS(oModel, cModelId) CLASS PCPA131API

	//Só executa a integração se estiver parametrizado como Online
	If ::lIntegraMRP == .F. .Or. ::lIntegraOnline == .F.
		Return
	EndIf

	integraAPI(oModel, Self)

Return Nil

/*/{Protheus.doc} integraAPI
Integra dados com a API
@author marcelo.neumann
@since 23/07/2019
@version P12
@param oModel, Object, Modelo principal
@param Self  , objeto, instancia atual desta classe
@return Nil
/*/
Static Function integraAPI(oModel, Self)
	Local aLines     := {}
	Local aDadosDel  := {}
	Local aDadosInc  := {}
	Local nIndex     := 0
	Local nTotal     := 0
	Local nPos       := 0
	Local oMdlSVX    := oModel:GetModel("SVX_MASTER")
	Local oMdlSVZ    := oModel:GetModel("SVZ_COMMIT")
	
	If oModel:GetOperation() == MODEL_OPERATION_DELETE
		nTotal := oMdlSVZ:Length()
		//Adiciona todas as datas que devem ser deletadas
		For nIndex := 1 To nTotal
			aAdd(aDadosDel,Array(ARRAY_CALENDAR_SIZE))
			nPos  := Len(aDadosDel)

			//Adiciona as informações no array de exclusão
			aDadosDel[nPos][ARRAY_CALENDAR_POS_FILIAL] := oMdlSVX:GetValue("VX_FILIAL")
			aDadosDel[nPos][ARRAY_CALENDAR_POS_CALEND] := oMdlSVX:GetValue("VX_CALEND")
			aDadosDel[nPos][ARRAY_CALENDAR_POS_DATA  ] := oMdlSVZ:GetValue("VZ_DATA"  ,nIndex)
		Next nIndex
	Else
		//Busca apenas as linhas que tiveram alguma alteração.
		aLines := oModel:GetModel("SVZ_COMMIT"):GetLinesChanged()
		nTotal := Len(aLines)

		//Adiciona as linhas que sofreram alguma modificação.
		For nIndex := 1 To nTotal
			If oMdlSVZ:IsDeleted(aLines[nIndex]) .And. (oMdlSVZ:IsInserted(aLines[nIndex]) .OR. oMdlSVZ:GetDataID(aLines[nIndex]) == 0)
				Loop
			EndIf
			If !oMdlSVZ:GetValue("SVZ_INTLIN",aLines[nIndex])
				Loop
			EndIf

			If oMdlSVZ:IsDeleted(aLines[nIndex])
				//Adiciona nova linha no array de exclusão.
				aAdd(aDadosDel,Array(ARRAY_CALENDAR_SIZE))
				nPos := Len(aDadosDel)

				//Adiciona as informações no array de exclusão
				aDadosDel[nPos][ARRAY_CALENDAR_POS_FILIAL] := oMdlSVX:GetValue("VX_FILIAL")
				aDadosDel[nPos][ARRAY_CALENDAR_POS_CALEND] := oMdlSVX:GetValue("VX_CALEND")
				aDadosDel[nPos][ARRAY_CALENDAR_POS_DATA  ] := oMdlSVZ:GetValue("VZ_DATA",aLines[nIndex])
			Else
				//Adiciona nova linha no array de inclusão/atualização.
				aAdd(aDadosInc,Array(ARRAY_CALENDAR_SIZE))
				nPos := Len(aDadosInc)

				//Adiciona as informações no array de inclusão/atualização.
				aDadosInc[nPos][ARRAY_CALENDAR_POS_FILIAL] := oMdlSVX:GetValue("VX_FILIAL")
				aDadosInc[nPos][ARRAY_CALENDAR_POS_CALEND] := oMdlSVX:GetValue("VX_CALEND")
				aDadosInc[nPos][ARRAY_CALENDAR_POS_DATA  ] := oMdlSVZ:GetValue("VZ_DATA"   ,aLines[nIndex])
				aDadosInc[nPos][ARRAY_CALENDAR_POS_HRAINI] := oMdlSVZ:GetValue("VZ_HORAINI",aLines[nIndex])
				aDadosInc[nPos][ARRAY_CALENDAR_POS_HRAFIM] := oMdlSVZ:GetValue("VZ_HORAFIM",aLines[nIndex])
				aDadosInc[nPos][ARRAY_CALENDAR_POS_INTER ] := oMdlSVZ:GetValue("VZ_INTERVA",aLines[nIndex])

				//Tratativa para enviar a filial correta.
				If Empty(aDadosInc[nPos][ARRAY_CALENDAR_POS_FILIAL])
					//Quando é uma linha que foi incluída na grid, o modelo ainda não possui o valor da filial.
					aDadosInc[nPos][ARRAY_CALENDAR_POS_FILIAL] := xFilial("SVX")
				EndIf
			EndIf
		Next nIndex
	EndIf

	If Len(aDadosDel) > 0
		PCPA131INT("DELETE", aDadosDel)
	EndIf

	If Len(aDadosInc) > 0
		PCPA131INT("INSERT", aDadosInc)
	EndIf

Return

/*/{Protheus.doc} PCPA131INT
Função que executa a integração de CALENDARas com o MRP.
@type  Function
@author marcelo.neumann
@since 23/07/2019
@version P12
@param cOperation, Caracter, Operação que será executada ('DELETE' ou 'INSERT')
@param aDados    , Array   , Array com os dados que devem ser integrados com o MRP.
@param aSuccess  , Array   , Carrega os registros que foram integrados com sucesso
@param aError    , Array   , Carrega os registros que não foram integrados por erro
@param lOnlyDel  , Logic   , Indica que está sendo executada uma operação de Sincronização apenas excluindo os dados existentes (envia somente filial).
@param lBuffer, Lógico, Define a sincronização em processo de buffer.
@return Nil
/*/
Function PCPA131INT(cOperation, aDados, aSuccess, aError, lOnlyDel, lBuffer)
	Local aReturn   := {}
	Local cApi      := "MRPCALENDAR"
	Local lAllError := .F.
	Local nIndex    := 0
	Local nIndExcl  := 0
	Local nIndIncl  := 0
	Local nTotal    := 0
	Local nTotMinut := 0
	Local oJsonExcl := Nil
	Local oJsonIncl := Nil

	Default aSuccess := {}
	Default aError   := {}	
	Default lOnlyDel := .F.
	Default lBuffer  := .F.
	
	If _lMrpInSMQ  .and. cOperation != "SYNC" .and. !mrpInSMQ(xFilial("SVZ"))
		Return nil	
	EndIf

	nTotal := Len(aDados)
	If cOperation == "SYNC" .And. lOnlyDel
		oJsonIncl := JsonObject():New()
		oJsonIncl["items"] := {}

		For nIndex := 1 To nTotal
			nIndIncl++
			AAdd(oJsonIncl["items"], JsonObject():New())
			oJsonIncl["items"][nIndIncl]["branchId"] := aDados[nIndex][ARRAY_CALENDAR_POS_FILIAL]
		Next nIndex
		
	ElseIf nTotal > 0
		oJsonIncl := JsonObject():New()
		oJsonIncl["items"] := {}

		oJsonExcl := JsonObject():New()
		oJsonExcl["items"] := {}

		For nIndex := 1 To nTotal
			nTotMinut := 0
			If cOperation $ "|INSERT|SYNC|"
				nTotMinut := Hrs2Min(aDados[nIndex][ARRAY_CALENDAR_POS_HRAFIM]) - ;
							 Hrs2Min(aDados[nIndex][ARRAY_CALENDAR_POS_HRAINI]) - ;
							 Hrs2Min(aDados[nIndex][ARRAY_CALENDAR_POS_INTER ])
			EndIf

			If cOperation $ "|INSERT|SYNC|"
				nIndIncl++
				AAdd(oJsonIncl["items"], JsonObject():New())

				oJsonIncl["items"][nIndIncl]["branchId"  ] := aDados[nIndex][ARRAY_CALENDAR_POS_FILIAL]
				oJsonIncl["items"][nIndIncl]["code"      ] := aDados[nIndex][ARRAY_CALENDAR_POS_FILIAL] + ;
														      aDados[nIndex][ARRAY_CALENDAR_POS_CALEND] + ;
														      DToS(aDados[nIndex][ARRAY_CALENDAR_POS_DATA])
				oJsonIncl["items"][nIndIncl]["calendar"  ] := aDados[nIndex][ARRAY_CALENDAR_POS_CALEND]
				oJsonIncl["items"][nIndIncl]["date"      ] := convDate(aDados[nIndex][ARRAY_CALENDAR_POS_DATA])
				oJsonIncl["items"][nIndIncl]["startTime" ] := aDados[nIndex][ARRAY_CALENDAR_POS_HRAINI]
				oJsonIncl["items"][nIndIncl]["endTime"   ] := aDados[nIndex][ARRAY_CALENDAR_POS_HRAFIM]
				oJsonIncl["items"][nIndIncl]["interval"  ] := aDados[nIndex][ARRAY_CALENDAR_POS_INTER ]
				oJsonIncl["items"][nIndIncl]["totalHours"] := trataHora( Min2Hrs(nTotMinut) )
			ElseIf cOperation != "SYNC"
				nIndExcl++
				AAdd(oJsonExcl["items"], JsonObject():New())

				oJsonExcl["items"][nIndExcl]["branchId"] := aDados[nIndex][ARRAY_CALENDAR_POS_FILIAL]
				oJsonExcl["items"][nIndExcl]["code"    ] := aDados[nIndex][ARRAY_CALENDAR_POS_FILIAL] + ;
														    aDados[nIndex][ARRAY_CALENDAR_POS_CALEND] + ;
														    DToS(aDados[nIndex][ARRAY_CALENDAR_POS_DATA])
			EndIf
		Next nIndex
	EndIf
	
	If nIndIncl > 0
		If cOperation == "INSERT"
			aReturn := MrpCAPost(oJsonIncl)
		Else
			aReturn := MrpCASync(oJsonIncl,lBuffer)
		EndIf
		PrcPendMRP(aReturn, cApi, oJsonIncl, .F., @aSuccess, @aError, @lAllError, '1')
	EndIf

	If nIndExcl > 0
		aReturn := MrpCADel(oJsonExcl)
		PrcPendMRP(aReturn, cApi, oJsonExcl, .F., @aSuccess, @aError, @lAllError, '2')
	EndIf

	FreeObj(oJsonIncl)
	oJsonIncl := Nil
	FreeObj(oJsonExcl)
	oJsonExcl := Nil

Return Nil

/*/{Protheus.doc} convDate
Converte uma data do tipo DATE para o formato string AAAA-MM-DD
@type  Static Function
@author marcelo.neumann
@since 23/07/2019
@version P12
@param dData, Date, Data que será convertida
@return cData, Caracter, Data convertida para o formato utilizado na integração.
/*/
Static Function convDate(dData)

	Local cData := StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)

Return cData

/*/{Protheus.doc} trataHora
Converte uma data do tipo DATE para o formato string AAAA-MM-DD
@type  Static Function
@author marcelo.neumann
@since 23/07/2019
@version P12
@param nHora, Numérico, Hora que será convertida
@return cTotalHra, Caracter, Hora convertida para o formato utilizado na integração.
/*/
Static Function trataHora(nHora)

	Local cTotalHra := cValToChar(nHora)
	Local cHoras    := "00"
	Local cMinutos  := "00"
	Local nPosDivis := 0

	cTotalHra := StrTran(cTotalHra, ".", ":")
	nPosDivis := At(":", cTotalHra)

	If nPosDivis > 0
		cHoras   := PadL(SubStr(cTotalHra, 1, (nPosDivis-1)), 2, "0")
		cMinutos := PadR(SubStr(cTotalHra, (nPosDivis+1), 2), 2, "0")
	Else
		cHoras   := PadL(cTotalHra, 2, "0")
	EndIf

	cTotalHra := cHoras + ":" + cMinutos

Return cTotalHra

