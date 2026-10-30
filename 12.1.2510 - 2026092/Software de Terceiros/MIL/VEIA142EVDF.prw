#include 'TOTVS.ch'
#Include "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE 'VEIA142.CH'

CLASS VEIA142EVDF FROM FWModelEvent

	Data aCpoAlt

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD ModelPosVld()
	METHOD InTTS()
	METHOD VldActivate()

ENDCLASS



METHOD New() CLASS VEIA142EVDF

	::aCpoAlt   := {}

RETURN .T.


METHOD FieldPreVld(oModel, cModelID, cAction, cId, xValue) CLASS VEIA142EVDF

	Local nPosCpo := 0
	
	If cAction == "SETVALUE" .and. oModel:GetOperation() == 4
		if oModel:GetValue(cId) <> xValue

			cContAnt := oModel:GetValue(cId)
			cContNov := xValue

			cTpCpo := GeTSX3Cache(cId,"X3_TIPO")

			If cTpCpo == "N"
				cContAnt := cValToChar(cContAnt)
				cContNov := cValToChar(cContNov)
			ElseIf cTpCpo == "D"
				cContAnt := DtoC(cContAnt)
				cContNov := DtoC(cContNov)
			EndIf
			
			nPosCpo := aScan(self:aCpoAlt,{|x| x[1] == cId})
			If nPosCpo == 0
				aAdd(self:aCpoAlt,{cId,cContAnt,cContNov})
			Else
				self:aCpoAlt[nPosCpo,3] := cContNov
			EndIf

		EndIf
	EndIf

RETURN .t.

METHOD InTTS(oModel, cModelId) CLASS VEIA142EVDF

	Local nPos 		:= 0
	Local oVJS 		:= FWLoadModel( 'VEIA143' )
	Local oVV1 		:= FWLoadModel( 'VEIA070' )
	//Local cCodMar 	:= FMX_RETMAR(GetNewPar("MV_MIL0006",""))
	Local cCriaMaq 	:= ""
	Local lGerImport:= .f.
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aIteAux	:= {}
	Local lExistSC1 := .f.
	Local lVQ0CODSC1:= VQ0->(FieldPos("VQ0_CODSC1") > 0)

	Private lMSErroAuto := .f.

	If VQ0->(FieldPos("VQ0_IMPORT") > 0)
		lGerImport:= oModel:GetValue("VQ0MASTER","VQ0_IMPORT") == "1"
	EndIf

	cCriaMaq := VA140005G_GravaMaquina( oModel:GetValue( "VQ0MASTER", "VQ0_CHAINT"),;  // 01 - cChaInt
										oModel:GetValue( "VQ0MASTER", "VQ0_MODVEI"),;  // 02 - cModVei
										oModel:GetValue( "VQ0MASTER", "VQ0_CHASSI"),;  // 03 - cChassi
										oModel:GetValue( "VQ0MASTER", "VQ0_FILENT"),;  // 04 - cFilEnt
										oVV1,;  // 05 - oModelVei
										oModel:GetValue( "VQ0MASTER", "VQ0_CORVEI"),;  // 06 - cCor
										oModel:GetValue( "VQ0MASTER", "VQ0_SEGMOD"),;  // 07 - cSegMod
										iif( ! empty( oModel:GetValue( "VQ0MASTER", "VQ0_CODMAR") ) , oModel:GetValue( "VQ0MASTER", "VQ0_CODMAR") , FMX_RETMAR(GetNewPar("MV_MIL0006","")) ),;  // 08 - cCodMar
										If(lGerImport,GetMV("MV_LOCVEIN"),),;         // 09 - cLocPad
										lGerImport,;                                  // 10 - lVEIImp
										,;  // 11 - cCodImp
										,;  // 12 - cComarCod
										oModel:GetValue( "VQ0MASTER", "VQ0_NUMPED"),;  	// 13 - cNroPed
										oModel:GetValue( "VQ0MASTER", "VQ0_STATUS"),;  	// 14 - cStatusPed
										oModel:GetValue( "VQ0MASTER", "VQ0_DATPED"),;   // 15 - dPedido 
										iif(oModel:getValue( "VQ0MASTER", "VQ0_FATDIR") == "0","VENDA", "");// 16 - cTpVend
										 )	


	If ! Empty(cCriaMaq) .and. VQ0->VQ0_CHAINT <> cCriaMaq
		RecLock("VQ0", .f.)
			VQ0->VQ0_CHAINT := cCriaMaq
		MsUnLock()
	EndIf

	For nPos := 1 to Len(self:aCpoAlt)

		If self:aCpoAlt[nPos,2] <> self:aCpoAlt[nPos,3]

			oVJS:SetOperation( MODEL_OPERATION_INSERT )
			lRet := oVJS:Activate()

			if lRet

				oVJS:SetValue( "VJSMASTER", "VJS_CODVQ0", oModel:GetValue("VQ0MASTER","VQ0_CODIGO") )
				oVJS:SetValue( "VJSMASTER", "VJS_DATALT", dDataBase )
				oVJS:SetValue( "VJSMASTER", "VJS_CPOALT", self:aCpoAlt[nPos,1] )
				oVJS:SetValue( "VJSMASTER", "VJS_CONANT", self:aCpoAlt[nPos,2] )
				oVJS:SetValue( "VJSMASTER", "VJS_CONNOV", self:aCpoAlt[nPos,3] )

				If ( lRet := oVJS:VldData() )
					if ( lRet := oVJS:CommitData())
					Else
						Help("",1,"COMMITVJS",,oVJS:GetErrorMessage()[6],1,0)
					EndIf
				Else
					Help("",1,"VALIDVJS",,oVJS:GetErrorMessage()[6] + STR0041 + oVJS:GetErrorMessage()[2],1,0) //"Campo: "
				EndIf
				
				oVJS:DeActivate()

			Else
				Help("",1,"ACTIVEVJS",, STR0029 ,1,0) //"Não foi possivel ativar o modelo de inclusão da tabela"
			EndIf

		EndIf

	Next

	If lVQ0CODSC1
		lExistSC1 := SC1->(DbSeek( xFilial("SC1") + oModel:GetValue("VQ0MASTER","VQ0_CODSC1") ) )
	EndIf

	If lGerImport .and. !lExistSC1

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1")+Left(GetMv("MV_GRUVEI")+Space(10),Len(SB1->B1_GRUPO))+"_"+VQ0->VQ0_CHAINT)

		//Cabeçalho
		aAdd(aCabec,{"C1_NUM"     , oModel:GetValue("VQ0MASTER","VQ0_CODSC1") , Nil })
		aAdd(aCabec,{"C1_EMISSAO" , oModel:GetValue("VQ0MASTER","VQ0_EMISS")  , Nil })
		aAdd(aCabec,{"C1_FILENT"  , oModel:GetValue("VQ0MASTER","VQ0_FILENT") , Nil })
		aAdd(aCabec,{"C1_NATUREZ" , oModel:GetValue("VQ0MASTER","VQ0_NATURE") , Nil })
		aAdd(aCabec,{"C1_CODCOMP" , oModel:GetValue("VQ0MASTER","VQ0_CDCOMP") , Nil })
		aAdd(aCabec,{"C1_SOLICIT" , oModel:GetValue("VQ0MASTER","VQ0_SOLICI") , Nil })
		aAdd(aCabec,{"C1_SIGLA"   , oModel:GetValue("VQ0MASTER","VQ0_SIGLA")  , Nil })

		If VQ0->(FieldPos("VQ0_MOEDA")) > 0
			aAdd(aCabec,{"C1_MOEDA"   , oModel:GetValue("VQ0MASTER","VQ0_MOEDA")      , Nil })
		EndIf

		//Itens
		aAdd(aIteAux,{"C1_ITEM"    , StrZero(1,GeTSX3Cache("C1_ITEM","X3_TAMANHO")), Nil })
		aAdd(aIteAux,{"C1_PRODUTO" , SB1->B1_COD                                   , Nil })
		aAdd(aIteAux,{"C1_QUANT"   , 1                                             , Nil })
		aAdd(aIteAux,{"C1_PRECO"   , oModel:GetValue("VQ0MASTER","VQ0_VALINI")     , Nil })
		aAdd(aIteAux,{"C1_TOTAL"   , oModel:GetValue("VQ0MASTER","VQ0_VALINI")     , Nil })
		aAdd(aIteAux,{"C1_FILENT"  , oModel:GetValue("VQ0MASTER","VQ0_FILENT")     , Nil })
		aAdd(aIteAux,{"C1_SIGLA"   , oModel:GetValue("VQ0MASTER","VQ0_SIGLA")      , Nil })
		aAdd(aIteAux,{"C1_NATUREZ" , oModel:GetValue("VQ0MASTER","VQ0_NATURE")     , Nil })

		aAdd(aItens,aClone(aIteAux))

		MSExecAuto({|x,y,z,a| MATA113(x,y,z)},aCabec,aItens,3)
		If lMSErroAuto
			MostraErro()
			DisarmTransaction()
			Return .f.
		EndIf

	EndIf

	self:aCpoAlt := aSize(self:aCpoAlt,0)

	FreeObj(oVJS)
	FreeObj(oVV1)

RETURN .t. 

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA142EVDF

	Local cVQ0Cod := ""
	Local lGerImport := .f.

	If VQ0->(FieldPos("VQ0_IMPORT") > 0)
		lGerImport:= oModel:GetValue("VQ0MASTER","VQ0_IMPORT") == "1"
	EndIf

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		while ! empty( cVQ0Cod := FM_SQL("SELECT VQ0_CODIGO FROM " + RetSQLName("VQ0") + " WHERE VQ0_CODIGO = '" +oModel:GetValue("VQ0MASTER","VQ0_CODIGO")+ "' AND VQ0_FILIAL = '"+xFilial("VQ0")+"' AND D_E_L_E_T_ = ' '") )
			ConfirmSX8()
			oModel:loadValue("VQ0MASTER","VQ0_CODIGO", getSXEnum("VQ0", "VQ0_CODIO"))
		endDo

		If !Empty(cVQ0Cod)
			MsgStop(STR0044,STR0024) //Código do pedido já existe na base de dados, necessário consultar o controle de numeração. / Atenção
			Return .f.
		EndIf
	EndIf

	If lGerImport
		If Empty(oModel:GetValue("VQ0MASTER","VQ0_FILENT")) ;
			.or. Empty(oModel:GetValue("VQ0MASTER","VQ0_VALINI"));
			.or. Empty(oModel:GetValue("VQ0MASTER","VQ0_EMISS" ));
			.or. Empty(oModel:GetValue("VQ0MASTER","VQ0_NATURE"));
			.or. Empty(oModel:GetValue("VQ0MASTER","VQ0_CDCOMP"));
			.or. Empty(oModel:GetValue("VQ0MASTER","VQ0_SOLICI"));
			.or. Empty(oModel:GetValue("VQ0MASTER","VQ0_SIGLA" ))

			cMsgHelp := Alltrim(RetTitle("VQ0_FILENT")) ;
				+ " / " + Alltrim(RetTitle("VQ0_VALINI"));
				+ " / " + Alltrim(RetTitle("VQ0_EMISS"));
				+ " / " + Alltrim(RetTitle("VQ0_NATURE"));
				+ " / " + Alltrim(RetTitle("VQ0_CDCOMP"));
				+ " / " + Alltrim(RetTitle("VQ0_SOLICI"));
				+ " / " + Alltrim(RetTitle("VQ0_SIGLA"))

			FMX_HELP("VEIA142EVDFERR02", STR0051 + cMsgHelp,STR0046)//("Para prosseguir com a geração da solicitação da importação é necessário informar todos os campos: ". / Atencao")	 	

			RETURN .f.
		EndIf
	EndIf

RETURN .t.

 METHOD VldActivate(oModel, cModelId) CLASS VEIA142EVDF	
	Local nOperation := oModel:GetOperation()	
	Local aRet := {}

	If nOperation == 5
		aRet:= FGX_VEIMOVS( VQ0->VQ0_CHASSI , "E" , "0" )
		If Len(aRet) > 0			
			FMX_HELP("VEIA142EVDFERR01",STR0045,STR0046)//("Veiculo ja possui movimentação de Entrada. Impossivel continuar. / Atencao")	 	
			Return .f.		
		EndIf
	EndIf

RETURN .T.




