
#include 'TOTVS.ch'
#include "PROTHEUS.CH"
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#include "OFIA611.CH" // mesmo CH do OFIA611

CLASS OFIA611EVDEF FROM FWModelEvent

	Data aIteTrf
	Data aIteSug
	Data aIteRes
	Data aIteAtu

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()

	METHOD GetItensTransferencia()
	METHOD GetItensSugestaoCompra()
	METHOD GetItensReserva()
	METHOD GetAtualizaItens()

	METHOD SetItemTransferencia()
	METHOD SetItemSugestaoCompra()
	METHOD SetItemReserva()

ENDCLASS

/*/{Protheus.doc} New

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD New() CLASS OFIA611EVDEF

	::aIteRes := {}
	::aIteSug := {}
	::aIteTrf := {}
	::aIteAtu := {}

RETURN .T.

/*/{Protheus.doc} GridLinePreVld

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA611EVDEF

	Local lResItem := .f.

	If cModelId == "MODDET"
		If cAction == "SETVALUE"

			lCondErro := xValue - xCurrentValue > oSubModel:GetValue("QTDPEND")

			DbSelectArea("SB1")
			DbSetOrder(7)
			MSSeek(xFilial("SB1")+oSubModel:GetValue("GRUITE")+oSubModel:GetValue("CODITE"))

			If cId == "QTDTRA"

				If lCondErro
					FMX_HELP("OA611ERR001",STR0015) // "Quantidade informada é maior que a quantidade pendente."
					Return .f.
				EndIf

				If ::SetItemTransferencia(oSubModel,nLine,@xValue)
					lResItem := .t.
					oSubModel:SetValue("QTRARET",xValue) // Como não permite ajustar o valor digitado no SetValue, foi necessário criar um campo intermediario para armazenar o conteudo ajustado
				Else
					Return .f.
				EndIf

			ElseIf cId == "QTDAGU"

				If lCondErro
					FMX_HELP("OA611ERR002",STR0015) // "Quantidade informada é maior que a quantidade pendente."
					Return .f.
				EndIf

				If ::SetItemSugestaoCompra(oSubModel,xValue,nLine)
					lResItem := .t.
				EndIf

			EndIf

			If lResItem
				::SetItemReserva(oSubModel,xValue)
			EndIf

		EndIf
	EndIf

RETURN .t.

/*/{Protheus.doc} SetItemTransferencia

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD SetItemTransferencia(oSubModel,nLine,nQtdDig) CLASS OFIA611EVDEF

	Local aPedTra2 := {}
	Local lOFX011  := FWSX1Util():ExistPergunte("OFX011")
	Local nFilSemEst := 1

	Local nCntFor4 := 0
	Local nPosTrf  := 0
	Local aPedTransf := {}

	Local oModel	:= FWModelActive()
	oModPar := oModel:GetModel('MODPARAM')

	DbSelectArea("SB1")
	DbSetOrder(7)
	SB1->(DbSeek(xFilial("SB1")+oSubModel:GetValue("GRUITE")+oSubModel:GetValue("CODITE")))

	If lOFX011 .and. oModPar:GetValue("PARTIPOOP") <> "3"
		Pergunte( "OFX011" , .F.)
		nFilSemEst := MV_PAR01
	EndIf

	IF nQtdDig == 0

		nPosTrf := aScan( ::aIteTrf,{ |x| x[1] == nLine } )

		If nPosTrf > 0

			aDel( ::aIteTrf, nPosTrf )
			aSize( ::aIteTrf, LEN(::aIteTrf) - 1 )

			nPosAtu := aScan( ::aIteAtu, { |x| x[1] == nLine } )
			If nPosAtu > 0
				::aIteAtu[nPosAtu,3] := .f.
			EndIf

		EndIf

		Return .t.

	EndIf

	aPedTra2 := OXA020LBOX(oModPar:GetValue("PARFILIAL"),SB1->B1_GRUPO,SB1->B1_CODITE, nQtdDig, nFilSemEst)

	if ! Empty(aPedTra2)

		/*if lPediVenda
			For nCntFor4 := 1 to Len(aPedTra2) // [4]-qtd | [5]-filial
				OX0010074_AdicionaNATransferencia(oGetPecas:nAt, aPedTra2[nCntFor4])
			Next
		endif*/

		nQtdPTra := 0

		for nCntFor4 := 1 to Len(aPedTra2)

			nQtdPTra += aPedTra2[nCntFor4,4]

			nPos := aScan(aPedTransf,{|x| x[1]+x[2]+x[5] == aPedTra2[nCntFor4,1]+aPedTra2[nCntFor4,2]+aPedTra2[nCntFor4,5]})
			if nPos == 0
				aAdd(aPedTransf,aPedTra2[nCntFor4])
			endif
		next

		nQtdDig := nQtdPTra

		If Len(aPedTransf) > 0

			
			nPosTrf := aScan( ::aIteTrf,{ |x| x[1] == nLine } )
			/*
			[1] - Linha na grid
			[2] - Vetor com as quantidades e filiais
			*/
			If nPosTrf == 0

				aAdd(::aIteTrf,{nLine,aPedTransf})

				nPosAtu := aScan( ::aIteAtu, { |x| x[1] == nLine } )
				If nPosAtu == 0
					/*
						[1] Linha da grid
						[2] RecNo do registro
						[3] Indicador de Sugestão de Compra
						[4] Indicador de Transferência
					*/
					aAdd(::aIteAtu,{nLine,oSubModel:GetValue("RECREG"),.f.,.t.})
				Else
					::aIteAtu[nPosAtu,4] := .t.
				EndIf

			EndIf
		Endif

	Else
		Return .f.
	endif

Return .t.

/*/{Protheus.doc} GetAtualizaItens

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD GetAtualizaItens() CLASS OFIA611EVDEF

Return ::aIteAtu

/*/{Protheus.doc} GetItensTransferencia

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD GetItensTransferencia() CLASS OFIA611EVDEF

Return ::aIteTrf

/*/{Protheus.doc} SetItemSugestaoCompra

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD SetItemSugestaoCompra(oSubModel,nQtdDig,nLine) CLASS OFIA611EVDEF

	Local nPosSug := 0
	Local oModel  := FWModelActive()
	Local nPosCpo := 0
	Local cSequen := ""

	oModPar := oModel:GetModel('MODPARAM')

	cSequen := oSubModel:GetValue("SEQUEN")
	cPesq   := cSequen
	nPosCpo := 13 // posição campo Sequencial
	cCodVSJ := ""
	If oModPar:GetValue("PARTIPOOP") == "3"
		cSequen := ""
		cCodVSJ := oSubModel:GetValue("CODVSJ")
		cPesq   := cCodVSJ // Posição campo Codigo VSJ
		nPosCpo := 28
	EndIf

	nPosSug := aScan( ::aIteSug, { |x| x[2]+x[3]+x[nPosCpo] == oSubModel:GetValue("GRUITE")+oSubModel:GetValue("CODITE")+cPesq } ) // Grupo do Item + Codigo do Item + Sequencial

	If nPosSug == 0

		aAuxSug := Array(29)

		//Posições relevantes para geração da sugestão de compra ( Demais posições são para compatibilidade )
		aAuxSug[02] := oSubModel:GetValue("GRUITE")
		aAuxSug[03] := oSubModel:GetValue("CODITE")
		aAuxSug[04] := SB1->B1_DESC
		aAuxSug[05] := nQtdDig
		aAuxSug[08] := oSubModel:GetValue("QTDEST")
		aAuxSug[12] := SB1->B1_COD
		aAuxSug[14] := oSubModel:GetValue("QTDITE")
		aAuxSug[15] := oSubModel:GetValue("QTDEST")
		aAuxSug[16] := oSubModel:GetValue("LOCARM")
		aAuxSug[13] := cSequen
		aAuxSug[28] := cCodVSJ

		aAdd(::aIteSug,aClone(aAuxSug))

		nPosAtu := aScan( ::aIteAtu, { |x| x[1] == nLine } )
		If nPosAtu == 0
			/*
				[1] Linha da grid
				[2] RecNo do registro
				[3] Indicador de Sugestão de Compra
				[4] Indicador de Transferência
			*/
			aAdd(::aIteAtu,{nLine,oSubModel:GetValue("RECREG"),.t.,.f.})
		Else
			::aIteAtu[nPosAtu,3] := .t.
		EndIf

	Else

		If nQtdDig == 0

			aDel( ::aIteSug, nPosSug )
			aSize( ::aIteSug, LEN(::aIteSug) - 1 )

			nPosAtu := aScan( ::aIteAtu, { |x| x[1] == nLine } )
			If nPosAtu > 0
				::aIteAtu[nPosAtu,3] := .f.
			EndIf

		Else
			::aIteSug[nPosSug,4] := nQtdDig
		EndIf

	EndIf

Return .t.

/*/{Protheus.doc} GetItensSugestaoCompra

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD GetItensSugestaoCompra() CLASS OFIA611EVDEF

Return ::aIteSug

/*/{Protheus.doc} SetItemReserva

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD SetItemReserva(oSubModel,nQtdDig) CLASS OFIA611EVDEF

	Local nPosRes := 0

	nPosRes := aScan(::aIteRes, { |x| x[1] == oSubModel:GetValue("RECREG") } )

	If nPosRes == 0
		aAdd(::aIteRes,{ oSubModel:GetValue("RECREG") ,0,""})
	Else
		If nQtdDig == 0
			aDel( ::aIteRes, nPosRes )
			aSize( ::aIteRes, LEN(::aIteRes) - 1 )
		EndIf
	EndIf

Return

/*/{Protheus.doc} GetItensReserva

	@type method
	@author Renato Vinicius
	@since 23/02/2026
/*/

METHOD GetItensReserva() CLASS OFIA611EVDEF

Return ::aIteRes
