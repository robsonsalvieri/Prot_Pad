#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
Static nRegAtu := 0
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421H
Rotina "Processar" da Ficha de Remessa.
Mesma estrutura do GTPA421B (tela de selecao Agencia/Periodo/Num.Ficha),

@type function
@author GTP
@since
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function GTPA421H()
	Local lFchAcerto:= .F.
	Local lAuto		:= .F.
	Local aAuto		:= {}
	
	GTPA421B(lFchAcerto, lAuto, aAuto)

	G6X->(DbGoTo(nRegAtu))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA421HLote(aFld)
Rotina de montagem de periodo a ser executado conforme os parametros digitados
de data inicio e final, gerando assim uma ficha por dia.

@type function
@author GTP
@since
@version 1.0
@return Nil
/*/
//-------------------------------------------------------------------
Function GTPA421HLote(aFld)
	Local lRet     := .T.
	Local nDias    := 0
	Local nConta   := 0
	Local dDataIni := Ctod('//')
	Local dDataFim := Ctod('//')
	Local nPosIni  := aScan(aFld,{|x|AllTrim(x[1])== 'G6X_DTINI' })
	Local nPosFim  := aScan(aFld,{|x|AllTrim(x[1])== 'G6X_DTFIN' })
	Local nPosRem  := aScan(aFld,{|x|AllTrim(x[1])== 'G6X_DTREME' })
	Local nPosNum  := aScan(aFld,{|x|AllTrim(x[1])== 'G6X_NUMFCH' })
	Local nPosEnt  := aScan(aFld,{|x|AllTrim(x[1])== 'ENTREGUE' })
	Local oMdl421  := Nil 
	Local aAux     := aClone(aFld)
	Local dDataAux := dDataBase
	Local dDataRem := Ctod('//')
	Local lCommit  := .F.
	Local aErrorMsg:= {}

	If nPosIni > 0
		dDataIni := aFld[nPosIni][2]
	Endif

	If nPosFim > 0
		dDataFim := aFld[nPosFim][2]
	Endif

	If !Empty(dDataIni) .And. !Empty(dDataFim)
		nDias := DateDiffDay(dDataIni, dDataFim)
		For nConta:= 0 To nDias
			dDataBase        := dDataIni
			aAux[nPosIni][2] := dDataIni
			aAux[nPosFim][2] := dDataIni
			dDataRem := dDataIni + 1
			aAux[nPosRem][2] := dDataRem
			aAux[nPosNum][2] := Dtos(aAux[nPosFim][2])
			lCommit  		 := .T.

			GTPA421InitFld(aAux)

			oMdl421  := FwLoadModel('GTPA421')

			oMdl421:SetOperation(MODEL_OPERATION_INSERT)
			oMdl421:Activate()
			oMdl421:GetModel('G6XMASTER'):SetValue('G6X_AUSENC', .T.)
			oMdl421:GetModel('G6XMASTER'):SetValue('G6X_AUSENC', .F.)

			If oMdl421:VldData()
				oMdl421:CommitData()
			Endif

			oMdl421:DeActivate()
			oMdl421:Destroy()
			oMdl421:= NIL

			oMdl421  := FwLoadModel('GTPA421')
			oMdl421:SetOperation(MODEL_OPERATION_UPDATE)
			oMdl421:Activate()	
			oMdl421:GetModel('G6XMASTER'):SetValue('G6X_AUSENC', .T.)
			oMdl421:GetModel('G6XMASTER'):SetValue('G6X_AUSENC', .F.)					
			If oMdl421:VldData()
				oMdl421:CommitData()
			Else
				lCommit   := .F.
				aErrorMsg := oMdl421:GetErrormessage()				
			Endif
			oMdl421:DeActivate()
			oMdl421:Destroy()
			oMdl421:= NIL

			If !lCommit 
				JurShowErro(aErrorMsg)	
				nConta := nDias + 1	// Força saída do laço
			Else 
				//Entregar Ficha
				If nPosEnt > 0 .And. aFld[nPosEnt][2] == "1"
					dDataBase := dDataRem
					A421EncFic()
				EndIf 
				dDataBase:= dDataAux
				dDataIni += 1
				aAux     := aClone(aFld)
				nRegAtu  := G6X->(Recno())
			Endif						
		Next nConta
	EndIf 

	GTPDestroy(aFld)
	GTPDestroy(aAux)
	GTPDestroy(aErrorMsg)
	dDataBase := dDataAux

Return lRet 
