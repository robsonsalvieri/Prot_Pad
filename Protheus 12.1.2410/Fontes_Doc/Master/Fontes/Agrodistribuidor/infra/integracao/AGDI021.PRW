
#INCLUDE "TOTVS.ch"
#Include "AGDI021.ch"
#DEFINE IE_PEDIDO_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService

/*/{Protheus.doc} AGDI021
Funcao executada pelo modulo de faturamento ao alterar um pedido de venda
@type function
@version 12
@author lindembergson.pacheco
@since 05/03/2025
@return variant, nil
/*/
Function AGDI021(oGetPV, oGetd)
	Local aAreaAtu 		:= GetArea()
	Local lRet  := .T.
	Local nPosCliente
	Local nPosLoja

	Local oIEPedidoService := nil

	if SUPERGETMV("MV_SIGAAGD", .f., .f.) 
		IF ALTERA
			oIEPedidoService := IE_PEDIDO_SERVICE():New()
			if (oIEPedidoService:isPedidoInstrucEmbarque(SC5->C5_NUM))

				IF oGetPV != NIL
					nPosCliente := Ascan(oGetPV:aEntryCtrls,{|x| UPPER(TRIM(x:cReadVar))=="M->C5_CLIENTE"}) 
					If nPosCliente > 0
						oGetPV:aEntryCtrls[nPosCliente]:lReadOnly := .T.
					EndIf

					nPosLoja := Ascan(oGetPV:aEntryCtrls,{|x| UPPER(TRIM(x:cReadVar))=="M->C5_LOJACLI"})
					If nPosLoja > 0
						oGetPV:aEntryCtrls[nPosLoja]:lReadOnly := .T.
					EndIf
				ENDIF
				
				IF !EMPTY(M->C5_CLIENT)
					IF (M->C5_CLIENT !=  SC5->C5_CLIENT)
						M->C5_CLIENT :=  SC5->C5_CLIENT
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_LOJAENT)
					IF (M->C5_LOJAENT !=  SC5->C5_LOJAENT)
						M->C5_LOJAENT :=  SC5->C5_LOJAENT
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_CONDPAG)
					IF (M->C5_CONDPAG !=  SC5->C5_CONDPAG)
						M->C5_CONDPAG :=  SC5->C5_CONDPAG
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_VEND1)
					IF (M->C5_VEND1 !=  SC5->C5_VEND1)
						M->C5_VEND1 :=  SC5->C5_VEND1
						M->C5_COMIS1 :=  SC5->C5_COMIS1
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_TABELA)
					IF (M->C5_TABELA !=  SC5->C5_TABELA)
						M->C5_TABELA :=  SC5->C5_TABELA
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_CODSAF)
					IF (M->C5_CODSAF !=  SC5->C5_CODSAF)
						M->C5_CODSAF :=  SC5->C5_CODSAF
						lRet := .F.
					ENDIF
				ENDIF

				IF !EMPTY(M->C5_TPFRETE)
					IF (M->C5_TPFRETE !=  SC5->C5_TPFRETE)
						M->C5_TPFRETE :=  SC5->C5_TPFRETE
						lRet := .F.
					ENDIF
				ENDIF

					IF !EMPTY(M->C5_FRETE)
					IF (M->C5_FRETE !=  SC5->C5_FRETE)
						M->C5_FRETE :=  SC5->C5_FRETE
						lRet := .F.
					ENDIF
				ENDIF

				IF oGetd != NIL
					oGetd:Disable()
				ENDIF

				IF !lRet
					AGDHELP(STR0001,  STR0002 ) //#"Atencao" # //"Este pedido possui instrução de embarque, por este motivo o tipo de modificação feita interfere com o que foi negociado. Por favor verifique."
				ENDIF
			endif
		ENDIF

		FreeObj(oIEPedidoService)

	endif

	restarea(aAreaAtu)

Return lRet
