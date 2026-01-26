#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE ANALITICO_MATRICULA				1
#DEFINE ANALITICO_CATEGORIA				2
#DEFINE ANALITICO_TIPO_ESTABELECIMENTO	3
#DEFINE ANALITICO_ESTABELECIMENTO		4
#DEFINE ANALITICO_LOTACAO				5
#DEFINE ANALITICO_NATUREZA				6
#DEFINE ANALITICO_TIPO_RUBRICA			7
#DEFINE ANALITICO_INCIDENCIA_CP			8
#DEFINE ANALITICO_INCIDENCIA_IRRF		9
#DEFINE ANALITICO_INCIDENCIA_FGTS		10
#DEFINE ANALITICO_DECIMO_TERCEIRO		11
#DEFINE ANALITICO_TIPO_VALOR			12
#DEFINE ANALITICO_VALOR					13
#DEFINE ANALITICO_MOTIVO_DESLIGAMENTO	14
#DEFINE ANALITICO_RECIBO				15
#DEFINE ANALITICO_VALOR_DEP				16
#DEFINE ANALITICO_PERIODO_REFERENCIA	17
#DEFINE ANALITICO_PGTO_DEMONSTRATIVO	18
#DEFINE ANALITICO_PGTO_DATA				19
#DEFINE ANALITICO_PGTO_EVENTO			20
#DEFINE ANALITICO_CRMEN			        21
#DEFINE ANALITICO_PISPASEP			    22
#DEFINE ANALITICO_ECONSIGNADO			23
#DEFINE ANALITICO_ECONSIGNADO_INTFIN	24
#DEFINE ANALITICO_ECONSIGNADO_NRDOC		25

Static __aRubrica	:= {}
Static __aCampos	:= {}
Static __oInsert	:= Nil
Static __lCanBulk	:= Nil
Static __cBanco		:= Nil

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFSocialReport

@type			class
@description	Classe com funções utilizadas nos Relatórios de Conferências do eSocial ( INSS/IRRF/FGTS ).
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
/*/
//---------------------------------------------------------------------
Class TAFSocialReport From LongNameClass

	Data oVOReport
	Data aStructV3N
	Data nTamFilial

	Method New() Constructor
	Method Upsert()
	Method Delete()
	Method GetRubrica()
	Method GetMotDes()

EndClass

//---------------------------------------------------------------------
/*/{Protheus.doc} New
@type			method
@description	Retorna a instância do objeto.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@return			self - Objeto para utilização nos relatórios totalizadores
/*/
//---------------------------------------------------------------------
Method New() Class TAFSocialReport

	self:oVOReport	:=	TAFVOReport():New()
	self:aStructV3N	:=	V3N->( DBStruct() )
	self:nTamFilial	:=	self:aStructV3N[aScan( self:aStructV3N, { |x| x[1] == "V3N_FILIAL" } ) ][3]

Return( self )

//---------------------------------------------------------------------
/*/{Protheus.doc} Upsert
@type			method
@description	Insere/atualiza um registro na tabela V3N.
@author			Victor A. Barbosa
@since			15/05/2019
@version		1.0
@param			cEvento	-	Código do Evento: S-1200|S-2299|S-2399|S-5001|S-5002|S-5003
@param			cOrigem	-	Origem da Gravação: 1=Folha|2=TAF|3=Governo-INSS|4=Governo-IRRF|5=Governo-FGTS
@param			cFilEvt	-	Filial do Evento
@param			oData	-	Objeto com os dados a ser inserido/atualizado
@param			lDelete	-	Indica se deve ser executado apenas a exclusão dos registros
/*/
//---------------------------------------------------------------------
Method Upsert(cEvento as character, cOrigem as character, cFilEvt as character, oData as object, lDelete as logical) Class TAFSocialReport

	Local lRecibo       as logical
	Local lIrrf			as logical
	Local lCallTafa422  as logical
	Local lInsertBulk	as logical
	Local lPisPasep     as logical
	Local lEconsig		as logical
	Local lValEco		as logical
	Local nAnalitico    as numeric
	Local nx            as numeric
	Local nValorDep     as numeric
	Local cMotDes       as character
	Local cNome         as character
	Local cProtocolo    as character
	Local cRecibo       as character
	Local cIndApu       as character
	Local cPerApu       as character
	Local cCPF          as character
	Local cInRecibos    as character
	Local cValPis		as character
	Local cCodInst		as character
	Local cNrDoc		as character
	Local aAnalitico    as array
	Local aBulk         as array
	Local aBulkOri1     as array
	Local aBulkOri2     as array
	
	lRecibo       := .F.
	lIrrf		  := .F.
	nAnalitico    := 0
	nx            := 0
	nValorDep     := 0
	cMotDes       := ""
	cNome         := ""
	cProtocolo    := ""
	cRecibo       := ""
	cIndApu       := ""
	cPerApu       := ""
	cCPF          := ""
	cInRecibos    := ""
	cValPis		  := ""
	cCodInst	  := ""
	cNrDoc		  := ""
	lCallTafa422  := !FwIsInCallStack("SaveModel") .AND. FwIsInCallStack("TAF422Grv")
	lInsertBulk	  := __oInsert == Nil .Or. (__oInsert != nil .and. Len(__aCampos) < 25 ) .Or. FwIsInCallStack("TAFUPDV3N")
	lPisPasep     := TafColumnPos("V3N_PISPAS")
	lEconsig	  := TafColumnPos("V3N_CONSG")
	lValEco		  := .F.
	aAnalitico    := {}
	aBulk         := {}
	aBulkOri1     := {}
	aBulkOri2     := {}

	Default cEvento		:= ""
	Default cOrigem		:= ""
	Default	cFilEvt		:= ""
	Default lDelete		:= .F.
	Default oData		:= Nil

	If oData != Nil

		cNome	:= oData:GetNome()
		cRecibo	:= oData:GetRecibo()
		cIndApu	:= PadR(oData:GetIndApu(), GetSX3Cache("V3N_INDAPU", "X3_TAMANHO"))
		cPerApu	:= PadR(oData:GetPeriodo(), GetSX3Cache("V3N_PERAPU", "X3_TAMANHO"))
		cCPF	:= PadR(oData:GetCPF(), GetSX3Cache("V3N_CPF", "X3_TAMANHO"))
		cFilEvt := PadR(cFilEvt, self:nTamFilial)
		lRecibo := cOrigem $ '0|1|2' .And. Len(oData:aAnalitico) > 0 .And. (Len(oData:aAnalitico[1]) > 14 .And. oData:aAnalitico[1][15] <> Nil)
		lIrrf   := cEvento == "S-1210"
		cEvento := PadR(cEvento, GetSX3Cache("V3N_EVENTO", "X3_TAMANHO"))
		cOrigem := Padr(cOrigem, GetSX3Cache("V3N_ORIGEM", "X3_TAMANHO"))

		If lRecibo 
			For nx := 1 to len(oData:AANALITICO)

				If nX > 1
					cInRecibos += " , '" + oData:AANALITICO[nx][ANALITICO_RECIBO] + "'"
				Else
					cInRecibos += "'" + oData:AANALITICO[nx][ANALITICO_RECIBO] + "'"
				EndIf

			Next 

			self:Delete( cFilEvt , cIndApu , cPerApu , cCPF , cEvento , cOrigem , cInRecibos , .F., lRecibo )
		Else
			//Se existir dados para o FILIAL + INDAPU + PERAPU + CPF + EVENTO + ORIGEM então exclui, pois qualquer uma das informações do nível abaixo, pode ser alterada/exluída
			self:Delete( cFilEvt , cIndApu , cPerApu , cCPF , cEvento , cOrigem , '', .F., lRecibo, lIrrf )
		EndIf 

		If !lDelete

			aAnalitico := oData:GetAnalitico()

			If __lCanBulk == Nil

				If __cBanco == Nil
					__cBanco := TCGetDB()
				EndIf

				If (FindFunction("TAFisBDLegacy") .And. !TAFisBDLegacy())
					__lCanBulk := FwBulk():CanBulk()
				Else
					__lCanBulk := .F.
				EndIf

			EndIf

			If __lCanBulk
				
				If lInsertBulk 

					__oInsert 	:= FwBulk():New(RetSQLName("V3N"))
					__aCampos 	:= {{"V3N_FILIAL"	},;
									{"V3N_ID"		},;
									{"V3N_INDAPU"	},;
									{"V3N_PERAPU"	},;
									{"V3N_CPF"		},;
									{"V3N_NOME"		},;
									{"V3N_MATRIC"	},;
									{"V3N_CATEG"	},;
									{"V3N_TPINSC"	},;
									{"V3N_NRINSC"	},;
									{"V3N_CODLOT"	},;
									{"V3N_EVENTO"	},;
									{"V3N_ORIGEM"	},;
									{"V3N_RECIBO"	},;	
									{"V3N_NATRUB"	},;
									{"V3N_TPRUBR"	},;
									{"V3N_ITCP"		},;
									{"V3N_ITIRRF"	},;
									{"V3N_ITFGTS"	},;
									{"V3N_INDDEC"	},;
									{"V3N_TPVLR"	},;
									{"V3N_VALOR"	},;
									{"V3N_MOTDES"	},;
									{"V3N_VLRDEP"	}}

					If lCallTafa422
						AAdd(__aCampos, {"V3N_PERREF"})
						AAdd(__aCampos, {"V3N_DMDEV"})
						AAdd(__aCampos, {"V3N_DTPGTO"})
					EndIf

					If lCallTafa422
						AAdd(__aCampos, {"V3N_CRMEN"})
					EndIf

					If lPisPasep 
						AAdd(__aCampos, {"V3N_PISPAS"})
					EndIf

						If lEconsig
						AAdd(__aCampos, {"V3N_CONSG"})   
						AAdd(__aCampos, {"V3N_INSTFI"})
						AAdd(__aCampos, {"V3N_NRCRT"})
					EndIf

					__oInsert:SetFields(__aCampos)

				EndIf

				For nAnalitico := 1 To Len(aAnalitico)

					cProtocolo := IIf( !lRecibo	;
								  , cRecibo;
								  , aAnalitico[nAnalitico][ANALITICO_RECIBO] )
					cMotDes	   := IIf( Len(aAnalitico[nAnalitico]) >= 14 .And. ValType(aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO]) != "U";
								  , aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO];
								  , aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO] )
					nValorDep  := IIf( ValType(aAnalitico[nAnalitico][ANALITICO_VALOR_DEP] ) == "U";
								  , 0;
								  , aAnalitico[nAnalitico][ANALITICO_VALOR_DEP] )

					aBulk := {	cFilEvt																,; 
								TAFGeraID("TAF")													,;
								cIndApu																,;
								cPerApu																,;
								cCPF																,;
								AllTrim(cNome)														,;
								AllTrim(aAnalitico[nAnalitico][ANALITICO_MATRICULA])				,;
								aAnalitico[nAnalitico][ANALITICO_CATEGORIA]							,;
								aAnalitico[nAnalitico][ANALITICO_TIPO_ESTABELECIMENTO] 				,;
								aAnalitico[nAnalitico][ANALITICO_ESTABELECIMENTO]					,;
								aAnalitico[nAnalitico][ANALITICO_LOTACAO]							,;
								IIf(!lIrrf, cEvento, aAnalitico[nAnalitico][ANALITICO_PGTO_EVENTO]) ,;
								cOrigem																,;
								AllTrim(cProtocolo)													,;
								aAnalitico[nAnalitico][ANALITICO_NATUREZA]							,;
								aAnalitico[nAnalitico][ANALITICO_TIPO_RUBRICA]						,;
								aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_CP]						,;
								aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_IRRF]					,;
								aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_FGTS]					,;	
								aAnalitico[nAnalitico][ANALITICO_DECIMO_TERCEIRO]					,;
								aAnalitico[nAnalitico][ANALITICO_TIPO_VALOR]						,;
								aAnalitico[nAnalitico][ANALITICO_VALOR]								,;
								cMotDes																,;
								nValorDep															}

					If lCallTafa422
					
						aAdd(aBulk, IIf( Len(aAnalitico[nAnalitico]) >= 20 .And. ValType(aAnalitico[nAnalitico][ANALITICO_PERIODO_REFERENCIA] ) != "U";
									, aAnalitico[nAnalitico][ANALITICO_PERIODO_REFERENCIA]; 
									,"") )
						aAdd(aBulk, IIf( Len(aAnalitico[nAnalitico]) >= 20 .And. ValType(aAnalitico[nAnalitico][ANALITICO_PGTO_DEMONSTRATIVO] ) != "U";
									, aAnalitico[nAnalitico][ANALITICO_PGTO_DEMONSTRATIVO];
									, "") )
						aAdd(aBulk, IIf( Len(aAnalitico[nAnalitico]) >= 20 .And. ValType(aAnalitico[nAnalitico][ANALITICO_PGTO_DATA] ) != "U";
									, aAnalitico[nAnalitico][ANALITICO_PGTO_DATA];
									, CtoD("//") ))

						If Len(aAnalitico[nAnalitico]) >= 20 
							
							aAdd(aBulk, IIf(ValType(aAnalitico[nAnalitico][ANALITICO_CRMEN] ) == "U";
									, "";
									, aAnalitico[nAnalitico][ANALITICO_CRMEN]))
							
						EndIf	

					EndIf

					If lPisPasep 
						cValPis := IIf(ValType(aAnalitico[nAnalitico][ANALITICO_PISPASEP] ) == "U", "", aAnalitico[nAnalitico][ANALITICO_PISPASEP])
					 	aAdd(aBulk, cValPis) 
					EndIf

					If lEconsig
						lValEco := IIf(ValType(aAnalitico[nAnalitico][ANALITICO_ECONSIGNADO] ) == "U", "", aAnalitico[nAnalitico][ANALITICO_ECONSIGNADO])
					 	aAdd(aBulk, lValEco) 

						cCodInst := IIf(ValType(aAnalitico[nAnalitico][ANALITICO_ECONSIGNADO_INTFIN] ) == "U", "", aAnalitico[nAnalitico][ANALITICO_ECONSIGNADO_INTFIN])
					 	aAdd(aBulk, cCodInst) 

						cNrDoc := IIf(ValType(aAnalitico[nAnalitico][ANALITICO_ECONSIGNADO_NRDOC] ) == "U", "", aAnalitico[nAnalitico][ANALITICO_ECONSIGNADO_NRDOC])
					 	aAdd(aBulk, cNrDoc) 
					EndIf

					If cOrigem == "0"
						aBulkOri1 := aClone(aBulk)
						aBulkOri2 := aClone(aBulk)
						//Refaço os Ids para não gerar chave duplicada da refencia do array Pai
						aBulkOri1[2]  := TAFGeraID("TAF")
						aBulkOri1[13] := "1"

						aBulkOri2[2]  := TAFGeraID("TAF")
						aBulkOri2[13] := "2"

						__oInsert:AddData(aBulkOri1)
						__oInsert:AddData(aBulkOri2)

					Else
						__oInsert:AddData(aBulk)
					EndIf 

				Next
				
				__oInsert:Flush()
				__oInsert:Close()

			Else

				For nAnalitico := 1 To Len(aAnalitico)

					If RecLock("V3N", .T.)

						If cEvento == "S-1210"; cEvento := aAnalitico[nAnalitico][ANALITICO_PGTO_EVENTO]; EndIf
						V3N->V3N_FILIAL	:= cFilEvt
						V3N->V3N_ID		:= TAFGeraID("TAF")
						V3N->V3N_INDAPU	:= cIndApu
						V3N->V3N_PERAPU	:= cPerApu
						V3N->V3N_CPF	:= cCPF
						V3N->V3N_NOME	:= cNome
						V3N->V3N_MATRIC	:= aAnalitico[nAnalitico][ANALITICO_MATRICULA]
						V3N->V3N_CATEG	:= aAnalitico[nAnalitico][ANALITICO_CATEGORIA]
						V3N->V3N_TPINSC	:= aAnalitico[nAnalitico][ANALITICO_TIPO_ESTABELECIMENTO]
						V3N->V3N_NRINSC	:= aAnalitico[nAnalitico][ANALITICO_ESTABELECIMENTO]
						V3N->V3N_CODLOT	:= aAnalitico[nAnalitico][ANALITICO_LOTACAO]
						V3N->V3N_EVENTO	:= IIf(!lIrrf, cEvento, aAnalitico[nAnalitico][ANALITICO_PGTO_EVENTO])
						V3N->V3N_ORIGEM	:= cOrigem
						V3N->V3N_NATRUB	:= aAnalitico[nAnalitico][ANALITICO_NATUREZA]
						V3N->V3N_TPRUBR	:= aAnalitico[nAnalitico][ANALITICO_TIPO_RUBRICA]
						V3N->V3N_ITCP	:= aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_CP]
						V3N->V3N_ITIRRF	:= aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_IRRF]
						V3N->V3N_ITFGTS	:= aAnalitico[nAnalitico][ANALITICO_INCIDENCIA_FGTS]
						V3N->V3N_INDDEC	:= aAnalitico[nAnalitico][ANALITICO_DECIMO_TERCEIRO]
						V3N->V3N_TPVLR	:= aAnalitico[nAnalitico][ANALITICO_TIPO_VALOR]
						V3N->V3N_VALOR	:= aAnalitico[nAnalitico][ANALITICO_VALOR]
						V3N->V3N_RECIBO	:= IIf( lRecibo, aAnalitico[nAnalitico][ANALITICO_RECIBO], cRecibo) 
						V3N->V3N_MOTDES := IIf( Len(aAnalitico[nAnalitico]) >= 14 .And. ValType(aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO]) != "U";
										   , aAnalitico[nAnalitico][ANALITICO_MOTIVO_DESLIGAMENTO];
										   , "" )
						V3N->V3N_VLRDEP	:= IIf( ValType(aAnalitico[nAnalitico][ANALITICO_VALOR_DEP] ) == "U";
										   , 0;
										   , aAnalitico[nAnalitico][ANALITICO_VALOR_DEP] )
						If lCallTafa422

							V3N->V3N_PERREF := IIf( Len(aAnalitico[nAnalitico]) >= 20 .And. ValType(aAnalitico[nAnalitico][ANALITICO_PERIODO_REFERENCIA] ) != "U";
											   , aAnalitico[nAnalitico][ANALITICO_PERIODO_REFERENCIA];
											   , "" )
							V3N->V3N_DMDEV  := IIf( Len(aAnalitico[nAnalitico]) >= 20 .And. ValType(aAnalitico[nAnalitico][ANALITICO_PGTO_DEMONSTRATIVO] ) != "U";
											   , aAnalitico[nAnalitico][ANALITICO_PGTO_DEMONSTRATIVO];
											   , "" )
							V3N->V3N_DTPGTO := IIf( Len(aAnalitico[nAnalitico]) >= 20 .And. ValType(aAnalitico[nAnalitico][ANALITICO_PGTO_DATA] ) != "U";
											   , aAnalitico[nAnalitico][ANALITICO_PGTO_DATA];
											   , CtoD("//") )
							
							If Len(aAnalitico[nAnalitico]) >= 20
							
								V3N->V3N_CRMEN  := IIf( ValType(aAnalitico[nAnalitico][ANALITICO_CRMEN] ) == "U";
												   , "";
												   , aAnalitico[nAnalitico][ANALITICO_CRMEN] )
							
							EndIf

						EndIf

						V3N->(MsUnlock())

					EndIf

				Next

			EndIf

		EndIf

		oData:Clear()

	EndIf

Return

//---------------------------------------------------------------------
/*/{Protheus.doc} Delete
@type			method
@description	Deleta logicamente um ou mais registros na tabela V3N, respeitando a chave recebida por parâmetro.
@author			Victor A. Barbosa
@since			16/05/2019
@version		1.0

@param			cFilEvt	-	Filial do Evento
@param			cIndApu	-	Indicador de Período de Apuração
@param			cPerApu	-	Período de Apuração
@param			cCPF	-	CPF do Trabalhador
@param			cEvento	-	Código do Evento
@param			cOrigem	-	Origem da Gravação: 0=FOLHAeTAF|1=Folha|2=TAF|3=Governo-INSS|4=Governo-IRRF|5=Governo-FGTS
@param			cRecibo	-	Recibo do Evento de Origem
@param			lAll	-	Indica se deve excluir todas as ocorrências, sem considerar a origem
@param			lRecibo	-	Se filtra por Recibo de Origem (Gravações 1 e 2)
@param			lIrrf	-	Se trata-se de IR (não filtra por evento pois varia conforme dmDev/tpPgto do S-5002)
/*/
//---------------------------------------------------------------------
Method Delete( cFilEvt as Character, cIndApu as Character, cPerApu as Character, cCPF as Character, cEvento as Character,;
			   cOrigem as Character, cRecibo as Character, lAll as Logical, lRecibo as Logical, lIrrf as Logical ) Class TAFSocialReport

	Local cQryExec	as Character
	Local lOk		as Logical

	Default lAll	:= .F.
	Default lRecibo := .F.
	Default lIrrf 	:= .F.
	Default cRecibo := ""

	cQryExec := ""
	lOk      := .F.

	cQryExec := " DELETE FROM " + RetSqlName( "V3N" ) "
	cQryExec += " WHERE V3N_FILIAL = '" + cFilEvt 	+ "' "
	cQryExec += " AND V3N_INDAPU = '" 	+ cIndApu 	+ "' " 
	cQryExec += " AND V3N_PERAPU = '" 	+ cPerApu 	+ "' "

	If lIrrf
		cQryExec += " AND V3N_ORIGEM = '4' "	
	Else
		cQryExec += " AND V3N_EVENTO = '" 	+ cEvento 	+ "' "
	EndIf

	cQryExec += " AND D_E_L_E_T_ = '' "

	If !lAll

		IIF(cOrigem == "0", cOrigem := "1','2 ", cOrigem)

		If !Empty( cOrigem )
			cQryExec += " AND V3N_ORIGEM IN ('" + cOrigem + "') "
		EndIf
		
		If lRecibo
			cQryExec += " AND V3N_RECIBO IN (" + cRecibo + ") "
		EndIf
		
	EndIf
	
	If !Empty(cCPF)
		cQryExec += " AND V3N_CPF = '" 		+ cCPF 			+ "' "
	EndIf
	
	lOk := TcSQLExec( cQryExec ) >= 0

	If lOk
		TafConout( "Delete| Realizado na tabela  " + RetSqlName( "V3N" ))
	Else 	
		TafConout( "Delete| Não foi possível realizar a exclusão dos registros da tabela ";
								+ RetSqlName( "V3N" ) + ". Erro: "  + TCSQLError( ) )
	EndIf

Return()

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRubrica
@type			method
@description	Retorna um array com os dados da Rubrica.
@author			Victor A. Barbosa
@since			16/05/2019
@version		1.0
@param			cCodRubr	-	Código da Rubrica
@param			cIDTabRubr	-	Identificador da Tabela de Rubrica
@param			cPerApu		-	Período de referência
@param			lMultVinc	-	Indica se o evento de origem possui Múltiplos Vínculos
@param 			nTipPer     -   Tipo de Período: 1=Período Atual; 2=Período Anterior
@return			aRubr		-	Array com as informações da Rubrica
/*/ 
//---------------------------------------------------------------------
Method GetRubrica( cCodRubr as Character, cIDTabRubr as Character, cPerApu as Character, lMultVinc as Logical, nTipPer as Numeric ) Class TAFSocialReport

	Local aArea      as Array
	Local aFilMV     as Array
	Local aInfoSM0   as Array
	Local aRubr      as Array
	Local cAliasQry  as Character
	Local cCNPJRaiz  as Character
	Local cIdRubr    as Character
	Local cIncCP     as Character
	Local cIncFGTS   as Character
	Local cIncIRRF   as Character
	Local cNatureza  as Character
	Local cQuery     as Character
	Local cTipo      as Character
	LocaL cIncPis    as character
	Local lCont      as Logical
	LocaL lPisPas    as Logical
	Local nPosRubric as Numeric
	Local nRecnoC8R  as Numeric

	Default cIDTabRubr := ""
	Default cPerApu    := ""
	Default lMultVinc  := .F.
	Default nTipPer    := 1

	aArea      := GetArea()
	aFilMV     := {}
	aInfoSM0   := {}
	aRubr      := Array(7)
	cAliasQry  := ""
	cCNPJRaiz  := SubStr(SM0->M0_CGC, 1, 8)
	cIdRubr    := ""
	cIncCP     := ""
	cIncFGTS   := ""
	cIncIRRF   := ""
	cNatureza  := ""
	cQuery     := ""
	cTipo      := ""
	cIncPis    := ""
	lCont      := .F.
	lPisPas    := .T.
	nPosRubric := 0
	nRecnoC8R  := 0

	If !Empty(__aRubrica)
		nPosRubric := aScan(__aRubrica, {|r| r[1] + r[2] + r[3] == cCodRubr + cIDTabRubr + cPerApu .And. r[4] == lMultVinc .And. r[5] == nTipPer})
	EndIf

	If nPosRubric > 0

		aRubr := aClone(__aRubrica[nPosRubric][6])

	Else

		If lMultVinc

			aInfoSM0     	:= FWLoadSM0(.F.)
			
			aEval( aInfoSM0, { |x| Iif( SubStr( x[18], 1, 8 ) == cCNPJRaiz .and. x[1] == cEmpAnt, aAdd( aFilMV, x[2] ), Nil ) } )
			nRecnoC8R := MVQueryC8R(cCodRubr, cIDTabRubr, cPerApu, aFilMV, nTipPer)

			If nRecnoC8R > 0

				lCont := .T.
				C8R->( DBGoTo( nRecnoC8R ) )

			EndIf

		Else

			If FwIsInCallStack("TAFR124")

				cAliasQry := GetNextAlias()

				cQuery := " SELECT C8R.C8R_ID "
				cQuery += " FROM " + RetSqlName("C8R") + " C8R "
				cQuery += " WHERE C8R.C8R_FILIAL = '" + xFilial("C8R") + "' "
				cQuery += " AND C8R.C8R_IDTBRU = '" + cIDTabRubr + "' "
				cQuery += " AND C8R.C8R_CODRUB = '" + cCodRubr + "' "

				If Len(Alltrim(cPerApu)) == 6

					If Upper( AllTrim( TCGetDB() ) ) <> "MSSQL"
						cQuery += " AND SUBSTR( C8R.C8R_DTINI, 3, 4 ) || SUBSTR( C8R.C8R_DTINI, 1, 2 ) <= '" + cPerApu +  "' "
						cQuery += " AND ( SUBSTR( C8R.C8R_DTFIN, 3, 4 ) || SUBSTR( C8R.C8R_DTFIN, 1, 2 ) >= '" + cPerApu +  "' "
					Else
						cQuery += " AND CONCAT(SUBSTRING( C8R.C8R_DTINI, 3, 4 ), SUBSTRING( C8R.C8R_DTINI, 1, 2 )) <= '" + cPerApu +  "' "
						cQuery += " AND (CONCAT( SUBSTRING( C8R.C8R_DTFIN, 3, 4 ), SUBSTRING( C8R.C8R_DTFIN, 1, 2 )) >= '" + cPerApu +  "' "
					EndIf

					cQuery += " OR C8R.C8R_DTFIN = '' ) "

				ElseIf Len(Alltrim(cPerApu)) == 4

					If Upper( AllTrim( TCGetDB() ) ) <> "MSSQL"
						cQuery += " AND SUBSTR( C8R.C8R_DTINI, 3, 4 )  <= '" + cPerApu +  "' "
						cQuery += " AND SUBSTR( C8R.C8R_DTFIN, 3, 4 )  >= '" + cPerApu +  "' "
					Else
						cQuery += " AND SUBSTRING( C8R.C8R_DTINI, 3, 4 ) <= '" + cPerApu +  "' "
						cQuery += " AND (SUBSTRING( C8R.C8R_DTFIN, 3, 4 ) >= '" + cPerApu +  "' "
					EndIf

					cQuery += " OR C8R.C8R_DTFIN = '' ) "

				EndIf

				cQuery += " AND D_E_L_E_T_ = '' "
				cQuery += " ORDER BY C8R.C8R_ID DESC "
				cQuery := ChangeQuery( cQuery )

				TCQuery cQuery New Alias (cAliasQry)

				( cAliasQry )->( DBGoTop() )

				If ( cAliasQry )->( !Eof() )
					cIdRubr := ( cAliasQry )->C8R_ID
				EndIf

				C8R->( DBSetOrder( 5 ) ) //C8R_FILIAL+C8R_ID+C8R_ATIVO
				If C8R->( MsSeek( xFilial( "C8R" ) + cIdRubr + "1" ) )
					lCont := .T.
				EndIf
				
				(cAliasQry)->(DBCloseArea())

			Else

				If FwIsInCallStack("RptCharge")
					C8R->( DBSetOrder( 3 ) )
				Else 
					C8R->( DBSetOrder( 5 ) )
				EndIf

				If C8R->( MsSeek( xFilial( "C8R" ) + cCodRubr  + "1" ) )
					lCont := .T.
				Else 
					C8R->( DBSetOrder( 3 ) )
					If C8R->( MsSeek( xFilial( "C8R" ) + PadR( cCodRubr, TamSx3( "C8R_CODRUB" )[1])  + "1" ) )
						lCont := .T.
					EndIf
				EndIf

			EndIf

		EndIf

		If lCont

			If C89->( MsSeek( xFilial( "C89" ) + C8R->C8R_NATRUB ) )
				cNatureza := AllTrim( C89->C89_CODIGO )
			EndIf

			cTipo := AllTrim( C8R->C8R_INDTRB )

			If C8T->( MsSeek( xFilial( "C8T" ) + C8R->C8R_CINTPS ) )
				cIncCP := AllTrim( C8T->C8T_CODIGO )
			EndIf

			If C8U->( MsSeek( xFilial( "C8U" ) + C8R->C8R_CINTIR ) )
				cIncIRRF := AllTrim( C8U->C8U_CODIGO )
			EndIf

			cIncFGTS := AllTrim( C8R->C8R_CINTFG )

			cIncPis := AllTrim( C8R->C8R_CIPIPA )

			If Alltrim( cIncPis ) $ "91|92"
				lPisPas := TAFnrProc(  C8R->C8R_FILIAL, C8R->C8R_ID, C8R->C8R_VERSAO )
			EndIf

		EndIf

		aRubr[1] := cNatureza
		aRubr[2] := cTipo
		aRubr[3] := cIncCP
		aRubr[4] := cIncIRRF
		aRubr[5] := cIncFGTS
		aRubr[6] := cIncPis
		aRubr[7] := lPisPas

		AAdd(__aRubrica, {cCodRubr, cIDTabRubr, cPerApu, lMultVinc, nTipPer, aRubr})
	EndIf

	RestArea(aArea)

Return aRubr

//---------------------------------------------------------------------
/*/{Protheus.doc} GetMotDes
Retorna o motivo de afastamento do evento que gerou o totalizador

@type			method
@author			Fabio Mendonça
@since			26/07/2023
@version		1.0
@param			cAliEvtOri - Alias do registro que gerou o totalizador
@param			nRecEvtOri - RECNO do registro que gerou o totalizador
@return			cMotDes - Motivo de afastamento do evento que gerou o totalizador
/*/
//---------------------------------------------------------------------
Method GetMotDes(cAliEvtOri as Character, nRecEvtOri as Numeric) as Character Class TAFSocialReport

	Local aArea   as Array
	Local cMotDes as Character

	Default nRecEvtOri	:= 0
	
	aArea	:= {}
	cMotDes := ""

	If nRecEvtOri > 0
		aArea := GetArea()

		(cAliEvtOri)->(DbGoTo(nRecEvtOri))

		If cAliEvtOri == "CMD"
			C8O->(DbSetOrder(1))

			If C8O->(MsSeek(xFilial("C8O") + (cAliEvtOri)->&(cAliEvtOri + "_MOTDES")))
				cMotDes := AllTrim(C8O->C8O_CODIGO)
			EndIf

			C8O->(DbCloseArea())
		ElseIf cAliEvtOri == "T92"
			CML->(DbSetOrder(1))

			If CML->(MsSeek(xFilial("CML") + (cAliEvtOri)->&(cAliEvtOri + "_MOTDES")))
				cMotDes := AllTrim(CML->CML_CODIGO)
			EndIf

			CML->(DbCloseArea())
		EndIf

		RestArea(aArea)
	EndIf

Return cMotDes

/*/{Protheus.doc} TAFnrProc
Retorna os processos na rubrica especifica

@type			Função
@author			Alexandre de Lima Santos
@since			2703/2025
@version		1.0
@param			cFil 	- Filial da tabela para fazer a busca
@param			cId 	- Id da rubrica.
@return			cVersao - Versão do registro na tabela
/*/
//---------------------------------------------------------------------

Function TAFnrProc(  cFil as character, cId as Character, cVersao as character )
	
	LocaL aProc       as array
	Local cQry 		  as character
	Local cAliasQry   as character
	Local oStatement  as object
	
	Default cFil    := ""
	Default cId 	:= ""
	Default cVersao := ""

	aProc      := {}
	cQry       := ""
	oStatement := Nil
	oStatement := FWPreparedStatement():New()

	cQry := "SELECT T5N.T5N_IDPROC "
	cQry += "FROM " + RetSqlName("T5N") + " T5N "
	cQry += "WHERE "
	cQry += "T5N.T5N_FILIAL = ? "
	cQry += "AND T5N.T5N_ID = ? "
	cQry += "AND T5N.T5N_VERSAO = ? "
	cQry += "AND T5N.D_E_L_E_T_ = '' "

	cQry := ChangeQuery(cQry)

	//Define a consulta e os parâmetros
	oStatement:SetQuery(cQry)
	oStatement:SetString(1,cFil)
	oStatement:SetString(2,cId)
	oStatement:SetString(3,cVersao)

	cQry := oStatement:GetFixQuery()
	cAliasQry := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasQry, .F., .T. )

	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->( !Eof() )

		nPos := aScan( aProc, {|x| AllTrim(Upper(x)) == Alltrim((cAliasQry)->T5N_IDPROC )})

		If nPos == 0
			AAdd( aProc, (cAliasQry)->T5N_IDPROC )
		EndIf

		(cAliasQry)->( dbSkip() )
	EndDo
	
	(cAliasQry)->(dbCloseArea())

Return TAFIncd(  cFil, aProc )

//---------------------------------------------------------------------
/*/{Protheus.doc} TAFIncd
Verifica a incidenca para aplicar regra no relatoio de INSS (pispasep)

@type			Função
@author			Alexandre de Lima Santos
@since			27/03/2025
@version		1.0
@param			cFil 	- Filial da tabela para fazer a busca
@param			aSusp   - Array com Id's da tabela de processo S-1070
/*/
//---------------------------------------------------------------------
Function TAFIncd(  cFil as character, aSusp as Array )
	
	Local cQry 		as character
	Local cAliasQry as character
	Local nX        as Numeric
	Local lSumVal   as logical
	local oExec     as object
	
	Default aSusp   := {}
	Default cFil    := ""
	Default cId 	:= ""
	Default cVersao := ""

	aProc := {}
	cQry  := ""
	lSumVal := .T.
	oExec := Nil

	For nX := 1 to Len(aSusp)

		If oExec == Nil
		
			oExec := FWPreparedStatement():New()

			cQry := "SELECT T5L.T5L_INDDEC "
			cQry += "FROM " + RetSqlName("T5L") + " T5L "
			cQry += "WHERE "
			cQry += "T5L.T5L_FILIAL = ? "
			cQry += "AND T5L.T5L_ID = ? "
			cQry += "AND T5L.D_E_L_E_T_ = '' "

			cQry := ChangeQuery(cQry)
			
			//Define a consulta e os parâmetros
			oExec:SetQuery(cQry)
		EndIf

		oExec:SetString(1,cFil)
		oExec:SetString(2,aSusp[nX])

		cQry := oExec:GetFixQuery()
		cAliasQry := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry ) , cAliasQry, .F., .T. )

		(cAliasQry)->(DbGoTop())

		While (cAliasQry)->( !Eof() )

			dbSelectArea("C8S")
			dbSetOrder(1)
			If C8S->( dbSeek( xFilial("C8S") + (cAliasQry)->T5L_INDDEC ) )
				If C8S->C8S_CODIGO == '90'
					lSumVal := .F.
				EndIf
			EndIf
	
			(cAliasQry)->( dbSkip() )
		EndDo
			
		(cAliasQry)->(dbCloseArea())

	Next nX

Return lSumVal
