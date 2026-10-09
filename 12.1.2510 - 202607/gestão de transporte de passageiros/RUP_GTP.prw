#Include 'Protheus.ch'

#DEFINE	DF_CAMPO	1
#DEFINE	DF_CONTEUDO	2

//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_GTP()
Funções de compatibilização e/ou conversão de dados para as tabelas do sistema.
@sample		RUP_GTP("12", "2", "003", "005", "BRA")
@param		cVersion	- Versão do Protheus 
@param		cMode		- Modo de execução	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente está)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualização)
@param		cLocaliz	- Localização (país)	- Ex. "BRA"
@return		Nil
@author		jacomo.fernandes
@since		31/03/2017
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_GTP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Local aArea		:= GetArea()
Local aAreaSX2  := SX2->(GetArea())
Local aAreaSX3  := SX3->(GetArea())
Local aAreaSX7	:= SX7->(GetArea())
Local aSX3		:= {}
Local aDelSx2   := {}
Local aDelSx3	:= {}
Local aDelSx7	:= {}
Local aDelSx9	:= {}
Local aDelSix	:= {}

Default cMode	:= "1"

If cMode == "1" .And. ExistListSx3()
	aAdd(aDelSX7, {'GI2_CATEG ','002'})
	aAdd(aDelSX7, {'G56_CODVEI','001'})
	aAdd(aDelSX7, {'G56_SGSEGU','001'})
	aAdd(aDelSX7, {'G56_SGTIPO','001'})
	aAdd(aDelSX7, {'G56_VITIPO','001'})
	aAdd(aDelSX7, {'GI5_MOTORI','001'})
	aAdd(aDelSX7, {'GIB_AGENCI','001'})
	aAdd(aDelSX7, {'GIB_FILIAL','001'})
	aAdd(aDelSX7, {'GIB_LINHA ','001'})
	aAdd(aDelSX7, {'GIH_CODTER','001'})
	aAdd(aDelSX7, {'GIH_TPDOC ','001'})
	aAdd(aDelSX7, {'GIJ_CLICAR','001'})
	aAdd(aDelSX7, {'GIJ_LOJCAR','001'})
	aAdd(aDelSX7, {'GIS_CODREQ','001'})
	aAdd(aDelSX7, {'GIU_CODREQ','001'})
	aAdd(aDelSX7, {'GIY_VEICUL','001'})
	aAdd(aDelSX7, {'GIY_VEICUL','001'})
	aAdd(aDelSX7, {'GIZ_COD'   ,'001'})
	aAdd(aDelSX7, {'GIZ_VEICUL','001'})
	aAdd(aDelSX7, {'GQA_CODVEI','002'})

	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aDelSX7, {'GI2_LINHA' ,'001'})
	aAdd(aDelSX7, {'GIE_LINHA' ,'001'})
	aAdd(aDelSX7, {'GIE_LOCHOR','001'})
	aAdd(aDelSX7, {'GIN_DCHEGA','001'})
	aAdd(aDelSX7, {'GIN_HCHEGA','001'})
	aAdd(aDelSX7, {'GIO_CUSTO' ,'001'})
	aAdd(aDelSX7, {'GIO_CUSTO' ,'002'})
	aAdd(aDelSX7, {'GIO_CUSUNI','001'})
	aAdd(aDelSX7, {'GIO_FILIAL','001'})
	aAdd(aDelSX7, {'GIO_QUANT' ,'001'})
	aAdd(aDelSX7, {'GIO_UM'    ,'001'})
	aAdd(aDelSX7, {'GIP_CODBEM','001'})
	aAdd(aDelSX7, {'GIP_CODBEM','002'})
	aAdd(aDelSX7, {'GIP_CONFIG','001'})
	aAdd(aDelSX7, {'GIQ_TRECHO','001'})
	
	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aDelSX7, {'GQ8_CODLOC','001'})
	
	//tabelas que não precisam de validação de dicionário
	aAdd(aDelSX7, {'GY9_CODCAT','001'})
	aAdd(aDelSX7, {'GYY_CODACS','001'})

	IF Len(aDelSx7) > 0
		DelSx7(aDelSx7)
	Endif
	
	aAdd(aSx3,{"G6X_DESCAG"	,{ {'X3_INIBRW','POSICIONE("GI6",1,XFILIAL("GI6")+G6X->G6X_AGENCI,"GI6_DESCRI")'} } })
	aAdd(aSx3,{"GYT_DESCRI"	,{ {'X3_INIBRW','POSICIONE("GI1",1,XFILIAL("GI1")+GYT->GYT_LOCALI,"GI1_DESCRI")'} } })
	aAdd(aSx3,{"G6T_DESCRI"	,{ {'X3_INIBRW','fDesc("GI6",G6T->G6T_AGENCI,"GI6_DESCRI")'} } })
	aAdd(aSx3,{"GIC_NLOCOR"	,{ {'X3_INIBRW','fDesc("GI1", XFILIAL("GIC")+GIC->GIC_LOCORI,"GI1_DESCRI")'} } })    
	aAdd(aSx3,{"GIC_NLOCDE"	,{ {'X3_INIBRW','fDesc("GI1", XFILIAL("GIC")+GIC->GIC_LOCDES,"GI1_DESCRI")'} } })    
	aAdd(aSx3,{"G99_NOMREM"	,{ {'X3_INIBRW','fDesc("SA1", G99->G99_CLIREM+G99->G99_LOJREM,"A1_NOME") '} } })    
	aAdd(aSx3,{"G99_NOMDES"	,{ {'X3_INIBRW','fDesc("SA1", G99->G99_CLIDES+G99->G99_LOJDES,"A1_NOME") '} } })    
	aAdd(aSx3,{"G99_DESEMI"	,{ {'X3_INIBRW','fDesc("GI6", G99->G99_CODEMI,"GI6_DESCRI")              '} } })    
	aAdd(aSx3,{"G99_DESREC"	,{ {'X3_INIBRW','fDesc("GI6", G99->G99_CODREC,"GI6_DESCRI")              '} } })    
	aAdd(aSx3,{"G99_DESPRO"	,{ {'X3_INIBRW','fDesc("SB1", G99->G99_CODPRO,"B1_DESC")                 '} } })  
	aAdd(aSx3,{"GQH_TPDESC"	,{ {'X3_INIBRW','POSICIONE("GYA",1,XFILIAL("GYA")+GQH->GQH_TIPO,"GYA_DESCRI") '} } })
	aAdd(aSx3,{"GQH_TPDESC"	,{ {'X3_RELACAO','IIF(!INCLUI,POSICIONE("GYA",1,XFILIAL("GYA")+GQH->GQH_TIPO,"GYA_DESCRI"),"")'} } })
	aAdd(aSx3,{"GQP_DEPART"	,{ {'X3_VISUAL','A'} } })
	aAdd(aSx3,{"GYN_CONF"	,{ {'X3_RELACAO','2'} } })
	aAdd(aSx3,{"GQS_AGENCI"	,{ {'X3_VISUAL','A'} } })
	aAdd(aSx3,{"GIC_AGENCI"	,{ {'X3_VISUAL','A'} } })
	aAdd(aSx3,{"GYG_CPF"	,{ {'X3_VALID',''} } })


	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aSx3,{"G57_CODIGO"	,{ {'X3_F3','GIIFIL'} } })
	aAdd(aSx3,{"GI2_KMTOTA"	,{ {'X3_TAMANHO', 9} } }) 
	aAdd(aSx3,{"GI2_KMTOTA"	,{ {'X3_PICTURE', '@E 999,999.99'} } })
	aAdd(aSx3,{"GI8_AGENCI" ,{ {'X3_TAMANHO', 8} } }) 
	aAdd(aSx3,{"GI2_NUMMOV"	,{ {'X3_PICTURE', '999999999999'} } })
	aAdd(aSx3,{"GIE_NLOCHR"	,{ {'X3_INIBRW','POSICIONE("GI1",1,XFILIAL("GI1")+GIE->GIE_LOCHOR,"GI1_DESCRI"),"")'} } })
	aAdd(aSx3,{"GQL_CODIGO"	,{ {'X3_VISUAL','V'} } })

	// Ajuste para não gerar erro de tamnho de campo (Tarifa - GIC_TAR) na ficha de remessa
	aAdd(aSx3,{"GIC_TAR"	,{ {'X3_TAMANHO', 14} } }) 
	aAdd(aSx3,{"GIC_TAR"	,{ {'X3_PICTURE', '@E 99,999,999,999.99'} } })

	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aSx3,{"GY6_NOMEN1"	,{ {'X3_RELACAO',''} } })
	aAdd(aSx3,{"GY6_NOMEN2"	,{ {'X3_RELACAO',''} } })

	If Len(aSX3) > 0
		AjustaSx3(aSX3)
	Endif

	//Tabelas não utilizadas
	AADD(aDelSx2,"GY9")

	IF Len(aDelSx2) > 0
		DelSx2(aDelSx2)
	Endif

	aAdd(aDelSX9, {'G56','CAX'})
	aAdd(aDelSX9, {'G56','DA3'})
	aAdd(aDelSX9, {'G56','G57'})
	aAdd(aDelSX9, {'G56','G58'})
	aAdd(aDelSX9, {'G56','G59'})
	aAdd(aDelSX9, {'GI5','GYG'})
	aAdd(aDelSX9, {'GIB','GI2'})
	aAdd(aDelSX9, {'GIB','GI5'})
	aAdd(aDelSX9, {'GIB','GI6'})
	aAdd(aDelSX9, {'GIF','GI2'})
	aAdd(aDelSX9, {'GIH','GI7'})
	aAdd(aDelSX9, {'GIS','GIR'})
	aAdd(aDelSX9, {'GIT','GIR'})
	aAdd(aDelSX9, {'GIU','GIR'})
	aAdd(aDelSX9, {'GIW','DA4'})
	aAdd(aDelSX9, {'GIX','GI5'})
	aAdd(aDelSX9, {'GIY','DA3'})
	aAdd(aDelSX9, {'GIZ','DA3'})
	
	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aDelSX9, {'GYU','DA3'})
	aAdd(aDelSX9, {'GI8','GI7'})
	aAdd(aDelSX9, {'GI2','GY9'})
	aAdd(aDelSX9, {'GYI','GYG'})
	aAdd(aDelSX9, {'GIC','GZ2'})
	aAdd(aDelSX9, {'GIJ','SA1'})
	aAdd(aDelSX9, {'GIK','SA6'})
	aAdd(aDelSX9, {'GQG','GI1'})
	aAdd(aDelSX9, {'GQW','SQB'})
	aAdd(aDelSX9, {'G56','SX5'})
	
	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aDelSX9, {'GQB','SX5'})
	aAdd(aDelSX9, {'GQZ','SA1'})
	aAdd(aDelSX9, {'GQI','GI4'})
	aAdd(aDelSX9, {'GYD','GYA'})
	aAdd(aDelSX9, {'GYD','GYG'})
	
	//tabelas que não precisam de validação de dicionário
	aAdd(aDelSX9, {'GY9','GYR'})
	aAdd(aDelSX9, {'GYY','GYV'})
	aAdd(aDelSX9, {'GY9','GYR'})

	IF Len(aDelSx9) > 0
		DelSx9(aDelSx9)
	Endif

	// Carrega lista de campos
	aDelSx3:= LoadFields()

	If Len(aDelSx3) > 0
		DelSx3(aDelSx3)
	Endif

	aAdd(aDelSix, {'GI5','GI5_FILIAL+GI5_CPF'})
	aAdd(aDelSix, {'GIA','GIA_FILIAL+GIA_AGENCI'})
	aAdd(aDelSix, {'GIA','GIA_FILIAL+GIA_PREFIX+GIA_NUMTIT+GIA_PARCEL+GIA_FORNEC+GIA_LOJA'})
	aAdd(aDelSix, {'GIB','GIB_FILIAL+GIB_AGENCI'})
	aAdd(aDelSix, {'GIT','GIT_FILIAL+GIT_CODREQ'})
	aAdd(aDelSix, {'GIV','GIV_FILIAL+GIV_DESCRI'})
	aAdd(aDelSix, {'GQ8','GQ8_FILIAL+GQ8_CODIGO+GQ8_CODLOC+GQ8_TIPO+GQ8_TIPOAG'})
	aAdd(aDelSix, {'GQB','GQB_FILIAL+GQB_CODIGO+GQB_ITEM+GQB_SERVIC'})
	aAdd(aDelSix, {'GYD','GYD_FILIAL+GYD_CODLOT+GYD_CODTPD'})
	aAdd(aDelSix, {'GYD','GYD_FILIAL+GYD_CODIGO'})
	

	//tabelas que não precisam de validação de dicionário
	aAdd(aDelSix, {'GY9','GY9_FILIAL+GY9_CODIGO+GY9_CODORG+GY9_CODCAT'})
	aAdd(aDelSix, {'GY9','GY9_FILIAL+GY9_CODORG+GY9_CODCAT'})
	aAdd(aDelSix, {'GYY','GYY_FILIAL+GYY_CODVEI+GYY_CODACS'})
	aAdd(aDelSix, {'GYS','GYS_FILIAL+GYS_CODCAT+GYS_CODORG'})
	aAdd(aDelSix, {'GYS','GYS_FILIAL+GYS_CODIGO+GYS_CODORG'})

	IF Len(aDelSix) > 0
		DelSix(aDelSix)
	Endif

	AjusH60()

	CompatSX3Table()

EndIf

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aAreaSX7)
RestArea(aArea)


aSize(aSX3,0)
aSX3 := Nil

aSize(aDelSx7,0)
aDelSx7 := Nil

aSize(aDelSx3,0)
aDelSx3 := Nil

aSize(aDelSx9,0)
aDelSx9 := Nil

aSize(aDelSix,0)
aDelSix := Nil

Return Nil

/*/{Protheus.doc} AjustaSx3
Ajusta o Dicionário SX3
@type function
@author jacomo.fernandes
@since 11/04/2017
@version 1.0
@param aSx3, array, Array contendo os campos a serem alterados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function AjustaSx3(aSx3)
Local nInd1 := 0
Local nInd2 := 0
Local nTamX3CPO	:= Len(SX3->X3_CAMPO)

SX3->(DbSetOrder(2))//X3_CAMPO
For nInd1 := 1 to Len(aSx3)// Seleciona Campo
	If	SX3->( DbSeek( PadR( aSx3[nInd1][DF_CAMPO], nTamX3CPO ) ) )
		SX3->(RecLock("SX3",.F.))	
		For nInd2 := 1 to Len(aSx3[nInd1][2]) //Ajustes do Sx3

			//Macro Substituição dos campos do Sx3 
			SX3->&(aSx3[nInd1][2][nInd2][DF_CAMPO]) := aSx3[nInd1][2][nInd2][DF_CONTEUDO]
		
		Next
		SX3->(MSUnlock())
	EndIf
Next
Return

/*/{Protheus.doc} GTPRUP
(long_description)
@type function
@author jacom
@since 11/04/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPRUP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

Default cVersion		:= "12"
Default cMode			:= "1"
Default cRelStart		:= "014"
Default cRelFinish	    := "099"
Default cLocaliz		:= "BRA"

FwMsgRun( ,{||RUP_GTP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)},,"Executando RUP...")

Return()

/*/{Protheus.doc} DelSx7
Função para deletar relacionamento de tabela
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param aDelSx9, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx7(aDelSx7)
Local nInd1 := 0
Local nTamX7CPO	:= Len(SX7->X7_CAMPO)
Local nTamX7SEQ	:= Len(SX7->X7_SEQUENC)

//Mata os relacionamentos
DbSelectArea("SX7")
SX7->(DbSetOrder(1)) //X7_CAMPO+X7_SEQUENC
For nInd1 := 1 To Len(aDelSX7)


	If SX7->(DbSeek(PadR(aDelSX7[nInd1][1],nTamX7CPO)+(PadR(aDelSX7[nInd1][2],nTamX7SEQ))))
		If AllTrim(SX7->X7_CAMPO) == Alltrim(aDelSX7[nInd1][1]) .AND. AllTrim(SX7->X7_SEQUENC) == Alltrim(aDelSX7[nInd1][2])
			Reclock("SX7",.F.)
			SX7->( DbDelete() )
			SX7->(MsUnlock())
		EndIf
	EndIf
NEXT
Return

/*/{Protheus.doc} DelSx2
Função para deletar Tabela do dicionário
@type function
@author gtp
@since 18/06/2020
@version 1.0
@param aDelSx2, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx2(aDelSx2)
Local nInd1 	:= 0

dbSelectArea("SX2")
SX2->(dbSetOrder(1)) 

For nInd1 := 1 To Len(aDelSX2)

	If SX2->(dbSeek(aDelSX2[nInd1]))
		If AllTrim(SX2->X2_CHAVE) == Alltrim(aDelSX2[nInd1])
			Reclock("SX2",.F.)
			SX2->( dbDelete() )
			SX2->(MsUnlock())
		EndIf
	EndIf

Next

Return

/*/{Protheus.doc} DelSx3
Função para deletar campos do dicionário
@type function
@author flavio.martins
@since 22/01/2020
@version 1.0
@param aDelSx3, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx3(aDelSx3)
Local nInd1 	:= 0
Local nTamX3CPO	:= Len(SX3->X3_CAMPO)

dbSelectArea("SX3")
SX3->(dbSetOrder(2)) 

For nInd1 := 1 To Len(aDelSX3)

	If SX3->(dbSeek(Padr(aDelSX3[nInd1][2],nTamX3CPO)))
		If AllTrim(SX3->X3_CAMPO) == Alltrim(aDelSX3[nInd1][2])
			Reclock("SX3",.F.)
			SX3->( dbDelete() )
			SX3->(MsUnlock())
		EndIf
	EndIf

Next

Return

/*/{Protheus.doc} DelSIX
Função para deletar relacionamento de tabela
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param aDelSIX, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSIX(aDelSIX)
Local nInd1 	:= 0

//Mata os relacionamentos
DbSelectArea("SIX")
SIX->(DbSetOrder(1)) // INDICE+ORDEM
For nInd1 := 1 To Len(aDelSIX)
	If SIX->(DbSeek(aDelSIX[nInd1][1]))
		While SIX->(!Eof()) .and. SIX->INDICE = aDelSIX[nInd1][1] 
			If AllTrim(SIX->CHAVE) == aDelSIX[nInd1][2]
				Reclock("SIX",.F.)
				SIX->( DbDelete() )
				SIX->(MsUnlock())
				Exit
			Endif
			SIX->(DbSkip())
		End
	EndIf
Next

Return

/*/{Protheus.doc} DelSx9
Função para deletar relacionamento de tabela
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param aDelSx9, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function DelSx9(aDelSx9)
Local nInd1 := 0

//Mata os relacionamentos
DbSelectArea("SX9")
SX9->(DbSetOrder(2)) // X9_CDOM+X9_DOM
For nInd1 := 1 To Len(aDelSX9)
	If SX9->(DbSeek(aDelSX9[nInd1][1]+aDelSX9[nInd1][2] ))
		While SX9->(!Eof()) .and. SX9->X9_CDOM == aDelSX9[nInd1][1] .and. SX9->X9_DOM == aDelSX9[nInd1][2]
			//If SX9->X9_EXPCDOM == Padr(aDelSX9[nInd1][3] ,Len(SX9->X9_EXPCDOM)) .and. SX9->X9_EXPDOM == Padr(aDelSX9[nInd1][4] ,Len(SX9->X9_EXPDOM)) 
				Reclock("SX9",.F.)
				SX9->( DbDelete() )
				SX9->(MsUnlock())
				Exit
			//Endif
			SX9->(DbSkip())
		End
	EndIf
Next

Return

/*/{Protheus.doc} AjusH60
Função para incluir o H60_CODIGO como númerado único e sequêncial na tabela H60
@type function
@author Mick William da Silva
@since 04/04/2024
@version 1.0
@return .T.
/*/
Static Function AjusH60()
	Local _aStruct  := {}
	Local cTempTab	:= ""
	Local cQryDel	:= ""
	Local nMk		:= 0
	Local lCont		:= .T.
	Local cErro		:= "Não foi possível realizar a cópia da tabela H60."

	DBSelectArea("H60")
	H60->(DbGoTop())
	If H60->( ColumnPos('H60_CODIGO') ) <= 0 .OR. ( H60->( ColumnPos('H60_CODIGO') ) > 0 .And. Empty(Alltrim(H60->H60_CODIGO)) )

		_aStruct:= DBStruct()

		cTempTab:= "H60TMP_BKP"
		FWDBCreate(cTempTab, _aStruct, "TOPCONN", .T.)
		dbUseArea(.T., "TOPCONN",cTempTab,cTempTab, .T., .F.)
		DBCreateIndex(cTempTab+"1","H60_FILIAL+H60_CODG9O")

		If DBTblCopy('H60', cTempTab)
			BEGIN TRANSACTION	
				
				H60->(dbCloseArea())
				cQryDel := "DROP TABLE " + RetSQLName('H60')
				If (TCSQLExec(cQryDel) < 0)
					If H60->( ColumnPos('H60_CODIGO') ) > 0						
						cErro:= TCSQLError()
						lCont:= .F.
					EndIF
					If Select(cTempTab) > 0
						(cTempTab)->(dbCloseArea())
						TCSqlExec('DROP TABLE '+cTempTab)
					Endif
				EndIf

				If lCont
					(cTempTab)->(dbGotop())
					While !(cTempTab)->(EOF())
						DbSelectArea("H60")
						H60->(RecLock("H60", .T.))
							For nMk:= 1 To Len(_aStruct)
								If _aStruct[nMk][1] == "H60_CODIGO"
									H60->&(_aStruct[nMk][1]) := IIF(Empty(Alltrim((cTempTab)->H60_CODIGO)),GETSX8NUM('H60','H60_CODIGO'),(cTempTab)->H60_CODIGO)
								Else
									H60->&(_aStruct[nMk][1]) := (cTempTab)->&(_aStruct[nMk][1])
								EndIf
							Next nMk
						H60->(MsUnlock())
					(cTempTab)->(DbSkip())
					EndDo
					
					(cTempTab)->(dbCloseArea())
					TCSqlExec('DROP TABLE '+cTempTab)

				EndIf
			END TRANSACTION
		EndIf

		If !lCont
			Iif( !IsBlind(), FWAlertHelp(cErro,,"Erro na alteração estrutural da tabela H60"), FWLogMsg("ERROR","LAST","RUPGTP01",,,,cErro,,,))
			DisarmTransaction()
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} LoadFields
Função carrega lista de campos 
@type function
@author jacom
@since 11/04/2017
@version 1.0
@param a
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadFields( )

	Local aCampos := {}

	aAdd(aCampos, {'G56' ,'G56_CHANOM'})
	aAdd(aCampos, {'G56' ,'G56_CHCAMB'})
	aAdd(aCampos, {'G56' ,'G56_CHCOMB'})
	aAdd(aCampos, {'G56' ,'G56_CHCOMP'})
	aAdd(aCampos, {'G56' ,'G56_CHEIXO'})
	aAdd(aCampos, {'G56' ,'G56_CHMAPL'})
	aAdd(aCampos, {'G56' ,'G56_CHMARC'})
	aAdd(aCampos, {'G56' ,'G56_CHMDIF'})
	aAdd(aCampos, {'G56' ,'G56_CHMEDP'})
	aAdd(aCampos, {'G56' ,'G56_CHMODE'})
	aAdd(aCampos, {'G56' ,'G56_CHMODM'})
	aAdd(aCampos, {'G56' ,'G56_CHMORI'})
	aAdd(aCampos, {'G56' ,'G56_CHNUME'})
	aAdd(aCampos, {'G56' ,'G56_CHPOTM'})
	aAdd(aCampos, {'G56' ,'G56_CHQTPN'})
	aAdd(aCampos, {'G56' ,'G56_CHRDIF'})
	aAdd(aCampos, {'G56' ,'G56_CHRODA'})
	aAdd(aCampos, {'G56' ,'G56_CODVEI'})
	aAdd(aCampos, {'G56' ,'G56_CRACES'})
	aAdd(aCampos, {'G56' ,'G56_CRANO '})
	aAdd(aCampos, {'G56' ,'G56_CRBANH'})
	aAdd(aCampos, {'G56' ,'G56_CREMPE'})
	aAdd(aCampos, {'G56' ,'G56_CRMARC'})
	aAdd(aCampos, {'G56' ,'G56_CRMODE'})
	aAdd(aCampos, {'G56' ,'G56_CRNUME'})
	aAdd(aCampos, {'G56' ,'G56_CRSENT'})
	aAdd(aCampos, {'G56' ,'G56_CRTANQ'})
	aAdd(aCampos, {'G56' ,'G56_CRTIPO'})
	aAdd(aCampos, {'G56' ,'G56_CRVIDR'})
	aAdd(aCampos, {'G56' ,'G56_DCODVE'})
	aAdd(aCampos, {'G56' ,'G56_EPCATE'})
	aAdd(aCampos, {'G56' ,'G56_EPCERT'})
	aAdd(aCampos, {'G56' ,'G56_EPESTA'})
	aAdd(aCampos, {'G56' ,'G56_EPPLAC'})
	aAdd(aCampos, {'G56' ,'G56_EPRENA'})
	aAdd(aCampos, {'G56' ,'G56_SGABRA'})
	aAdd(aCampos, {'G56' ,'G56_SGAPOL'})
	aAdd(aCampos, {'G56' ,'G56_SGDSEG'})
	aAdd(aCampos, {'G56' ,'G56_SGDTIP'})
	aAdd(aCampos, {'G56' ,'G56_SGSEGU'})
	aAdd(aCampos, {'G56' ,'G56_SGTIPO'})
	aAdd(aCampos, {'G56' ,'G56_SGVENC'})
	aAdd(aCampos, {'G56' ,'G56_UTILIZ'})
	aAdd(aCampos, {'G56' ,'G56_VIDTIN'})
	aAdd(aCampos, {'G56' ,'G56_VIDTIP'})
	aAdd(aCampos, {'G56' ,'G56_VIDTVC'})
	aAdd(aCampos, {'G56' ,'G56_VINUME'})
	aAdd(aCampos, {'G56' ,'G56_VITIPO'})
	aAdd(aCampos, {'G5B' ,'G5B_ALIAS'})
	aAdd(aCampos, {'G5B' ,'G5B_CODIGO'})
	aAdd(aCampos, {'G5B' ,'G5B_DESCRI'})
	aAdd(aCampos, {'GI5' ,'GI5_CPF'})
	aAdd(aCampos, {'GI5' ,'GI5_MOTORI'})
	aAdd(aCampos, {'GI5' ,'GI5_NMOTOR'})
	aAdd(aCampos, {'GI5' ,'GI5_NOME  '})
	aAdd(aCampos, {'GI5' ,'GI5_STATUS'})
	aAdd(aCampos, {'GI7' ,'GI7_DESCRI'})
	aAdd(aCampos, {'GI7' ,'GI7_DTALT '})
	aAdd(aCampos, {'GI7' ,'GI7_DTINC '})
	aAdd(aCampos, {'GI7' ,'GI7_TIPO  '})
	aAdd(aCampos, {'GI9' ,'GI9_AGENCI'})
	aAdd(aCampos, {'GI9' ,'GI9_ITEM  '})
	aAdd(aCampos, {'GI9' ,'GI9_PERPED'})
	aAdd(aCampos, {'GI9' ,'GI9_PERSEG'})
	aAdd(aCampos, {'GI9' ,'GI9_PERTAR'})
	aAdd(aCampos, {'GI9' ,'GI9_PERTAX'})
	aAdd(aCampos, {'GI9' ,'GI9_VIGFIM'})
	aAdd(aCampos, {'GI9' ,'GI9_VIGINI'})
	aAdd(aCampos, {'GIA' ,'GIA_AGENCI'})
	aAdd(aCampos, {'GIA' ,'GIA_DATA  '})
	aAdd(aCampos, {'GIA' ,'GIA_DESCRI'})
	aAdd(aCampos, {'GIA' ,'GIA_DESFOR'})
	aAdd(aCampos, {'GIA' ,'GIA_DOC'})
	aAdd(aCampos, {'GIA' ,'GIA_FORNEC'})
	aAdd(aCampos, {'GIA' ,'GIA_LOJA'})
	aAdd(aCampos, {'GIA' ,'GIA_NUMTIT'})
	aAdd(aCampos, {'GIA' ,'GIA_PARCEL'})
	aAdd(aCampos, {'GIA' ,'GIA_PREFIX'})
	aAdd(aCampos, {'GIA' ,'GIA_VALPED'})
	aAdd(aCampos, {'GIA' ,'GIA_VALSEG'})
	aAdd(aCampos, {'GIA' ,'GIA_VALTAR'})
	aAdd(aCampos, {'GIA' ,'GIA_VALTAX'})
	aAdd(aCampos, {'GIA' ,'GIA_VALTOT'})
	aAdd(aCampos, {'GIB' ,'GIB_AGENCI'})
	aAdd(aCampos, {'GIB' ,'GIB_BILOK '})
	aAdd(aCampos, {'GIB' ,'GIB_BILTOT'})
	aAdd(aCampos, {'GIB' ,'GIB_DATA  '})
	aAdd(aCampos, {'GIB' ,'GIB_DESCRI'})
	aAdd(aCampos, {'GIB' ,'GIB_DTVIAG'})
	aAdd(aCampos, {'GIB' ,'GIB_HORAR '})
	aAdd(aCampos, {'GIB' ,'GIB_LINHA '})
	aAdd(aCampos, {'GIB' ,'GIB_LOTE  '})
	aAdd(aCampos, {'GIB' ,'GIB_MOTCOB'})
	aAdd(aCampos, {'GIB' ,'GIB_NLINHA'})
	aAdd(aCampos, {'GIB' ,'GIB_NUMFIM'})
	aAdd(aCampos, {'GIB' ,'GIB_NUMINI'})
	aAdd(aCampos, {'GIB' ,'GIB_OK'})
	aAdd(aCampos, {'GIB' ,'GIB_SENTID'})
	aAdd(aCampos, {'GIB' ,'GIB_SERIE '})
	aAdd(aCampos, {'GIB' ,'GIB_TPLOTE'})
	aAdd(aCampos, {'GIF' ,'GIF_CARRO '})
	aAdd(aCampos, {'GIF' ,'GIF_DATA  '})
	aAdd(aCampos, {'GIF' ,'GIF_DCHEGD'})
	aAdd(aCampos, {'GIF' ,'GIF_DCHERD'})
	aAdd(aCampos, {'GIF' ,'GIF_DCHERO'})
	aAdd(aCampos, {'GIF' ,'GIF_DSAIGO'})
	aAdd(aCampos, {'GIF' ,'GIF_HCHEGD'})
	aAdd(aCampos, {'GIF' ,'GIF_HCHERD'})
	aAdd(aCampos, {'GIF' ,'GIF_HCHERO'})
	aAdd(aCampos, {'GIF' ,'GIF_HORCAB'})
	aAdd(aCampos, {'GIF' ,'GIF_HSAIGO'})
	aAdd(aCampos, {'GIF' ,'GIF_LINHA '})
	aAdd(aCampos, {'GIF' ,'GIF_NLINHA'})
	aAdd(aCampos, {'GIF' ,'GIF_SENTID'})
	aAdd(aCampos, {'GIF' ,'GIF_SERVIC'})
	aAdd(aCampos, {'GIF' ,'GIF_TPVIA '})
	aAdd(aCampos, {'GIG' ,'GIG_AGENC '})
	aAdd(aCampos, {'GIG' ,'GIG_BILFIM'})
	aAdd(aCampos, {'GIG' ,'GIG_BILINI'})
	aAdd(aCampos, {'GIG' ,'GIG_DTFIM '})
	aAdd(aCampos, {'GIG' ,'GIG_DTINI '})
	aAdd(aCampos, {'GIG' ,'GIG_SERIE '})
	aAdd(aCampos, {'GIG' ,'GIG_TERCEI'})
	aAdd(aCampos, {'GIG' ,'GIG_TOTAL '})
	aAdd(aCampos, {'GIJ' ,'GIJ_CARTAO'})
	aAdd(aCampos, {'GIJ' ,'GIJ_CLICAR'})
	aAdd(aCampos, {'GIJ' ,'GIJ_DESCRI'})
	aAdd(aCampos, {'GIJ' ,'GIJ_LOJCAR'})
	aAdd(aCampos, {'GIJ' ,'GIJ_MVBCO '})
	aAdd(aCampos, {'GIJ' ,'GIJ_NCLICA'})
	aAdd(aCampos, {'GIK' ,'GIK_OK'})
	aAdd(aCampos, {'GIK' ,'GIK_VALOR '})
	aAdd(aCampos, {'GIK' ,'GIK_AGE'})
	aAdd(aCampos, {'GIK' ,'GIK_AGENCI'})
	aAdd(aCampos, {'GIK' ,'GIK_BCO'})
	aAdd(aCampos, {'GIK' ,'GIK_CTA'})
	aAdd(aCampos, {'GIK' ,'GIK_DATA'})
	aAdd(aCampos, {'GIK' ,'GIK_DTMOV'})
	aAdd(aCampos, {'GIK' ,'GIK_FORPAG'})
	aAdd(aCampos, {'GIK' ,'GIK_LOTE'})
	aAdd(aCampos, {'GIL' ,'GIL_AGE   '})
	aAdd(aCampos, {'GIL' ,'GIL_AGENCI'})
	aAdd(aCampos, {'GIL' ,'GIL_BCO   '})
	aAdd(aCampos, {'GIL' ,'GIL_CTA   '})
	aAdd(aCampos, {'GIL' ,'GIL_DATA  '})
	aAdd(aCampos, {'GIL' ,'GIL_LOTE  '})
	aAdd(aCampos, {'GIL' ,'GIL_NATURE'})
	aAdd(aCampos, {'GIL' ,'GIL_OK    '})
	aAdd(aCampos, {'GIL' ,'GIL_RECPAG'})
	aAdd(aCampos, {'GIL' ,'GIL_VALOR '})
	aAdd(aCampos, {'GIR' ,'GIR_APLIC '})
	aAdd(aCampos, {'GIR' ,'GIR_COD   '})
	aAdd(aCampos, {'GIR' ,'GIR_DESCRI'})
	aAdd(aCampos, {'GIR' ,'GIR_LINHAS'})
	aAdd(aCampos, {'GIS' ,'GIS_CODREQ'})
	aAdd(aCampos, {'GIS' ,'GIS_DESREQ'})
	aAdd(aCampos, {'GIS' ,'GIS_ITEM  '})
	aAdd(aCampos, {'GIS' ,'GIS_LINHA '})
	aAdd(aCampos, {'GIT' ,'GIT_CODREQ'})
	aAdd(aCampos, {'GIT' ,'GIT_DESREQ'})
	aAdd(aCampos, {'GIT' ,'GIT_DTFIM '})
	aAdd(aCampos, {'GIT' ,'GIT_DTINIC'})
	aAdd(aCampos, {'GIT' ,'GIT_VEICUL'})
	aAdd(aCampos, {'GIU' ,'GIU_CODREQ'})
	aAdd(aCampos, {'GIU' ,'GIU_DESREQ'})
	aAdd(aCampos, {'GIU' ,'GIU_DTFIM '})
	aAdd(aCampos, {'GIU' ,'GIU_DTINIC'})
	aAdd(aCampos, {'GIU' ,'GIU_ITEM  '})
	aAdd(aCampos, {'GIU' ,'GIU_MOTORI'})
	aAdd(aCampos, {'GIV' ,'GIV_COD   '})
	aAdd(aCampos, {'GIV' ,'GIV_DESCRI'})
	aAdd(aCampos, {'GIW' ,'GIW_ITEM  '})
	aAdd(aCampos, {'GIW' ,'GIW_LINHA '})
	aAdd(aCampos, {'GIW' ,'GIW_MOTORI'})
	aAdd(aCampos, {'GIW' ,'GIW_NMOTOR'})
	aAdd(aCampos, {'GIX' ,'GIX_COBRAD'})
	aAdd(aCampos, {'GIX' ,'GIX_ITEM  '})
	aAdd(aCampos, {'GIX' ,'GIX_LINHA '})
	aAdd(aCampos, {'GIX' ,'GIX_NCOBR '})
	aAdd(aCampos, {'GIY' ,'GIY_DESVEI'})
	aAdd(aCampos, {'GIY' ,'GIY_ITEM  '})
	aAdd(aCampos, {'GIY' ,'GIY_LINHA '})
	aAdd(aCampos, {'GIY' ,'GIY_VEICUL'})
	aAdd(aCampos, {'GIZ' ,'GIZ_COD'})
	aAdd(aCampos, {'GIZ' ,'GIZ_DESLOC'})
	aAdd(aCampos, {'GIZ' ,'GIZ_DESVEI'})
	aAdd(aCampos, {'GIZ' ,'GIZ_DTFIM '})
	aAdd(aCampos, {'GIZ' ,'GIZ_DTINIC'})
	aAdd(aCampos, {'GIZ' ,'GIZ_HORAEN'})
	aAdd(aCampos, {'GIZ' ,'GIZ_HORASA'})
	aAdd(aCampos, {'GIZ' ,'GIZ_KMENTR'})
	aAdd(aCampos, {'GIZ' ,'GIZ_KMSAID'})
	aAdd(aCampos, {'GIZ' ,'GIZ_LOCAL '})
	aAdd(aCampos, {'GIZ' ,'GIZ_VEICUL'})
	aAdd(aCampos, {'G9P' ,'G9P_CODG6X'})
	aAdd(aCampos, {'G9P' ,'G9P_NUMDOC'})
	aAdd(aCampos, {'G9P' ,'G9P_SERIE'})
	aAdd(aCampos, {'G9P' ,'G9P_VALOR'})
	aAdd(aCampos, {'GQJ' ,'GQJ_DESCRI'})
	aAdd(aCampos, {'GQJ' ,'GQJ_CLASSI'})
	aAdd(aCampos, {'GYX' ,'GYX_USER'})
	aAdd(aCampos, {'GYX' ,'GYX_HRCANC'})
	aAdd(aCampos, {'GYX' ,'GYX_DTCANC'})
	aAdd(aCampos, {'GYX' ,'GYX_STATUS'})
	aAdd(aCampos, {'GYX' ,'GYX_MOTOR2'})
	aAdd(aCampos, {'GYX' ,'GYX_MOTOR1'})
	aAdd(aCampos, {'GYX' ,'GYX_VEIC'})
	aAdd(aCampos, {'GYX' ,'GYX_HRPREV'})
	aAdd(aCampos, {'GYX' ,'GYX_DTPREV'})
	aAdd(aCampos, {'GYX' ,'GYX_HRVIAG'})
	aAdd(aCampos, {'GYX' ,'GYX_DTVIAG'})
	aAdd(aCampos, {'GYX' ,'GYX_KMREAL'})
	aAdd(aCampos, {'GYX' ,'GYX_KMPROV'})
	aAdd(aCampos, {'GYX' ,'GYX_INTFIM'})
	aAdd(aCampos, {'GYX' ,'GYX_LOCDES'})
	aAdd(aCampos, {'GYX' ,'GYX_INTINI'})
	aAdd(aCampos, {'GYX' ,'GYX_LOCOR'})
	aAdd(aCampos, {'GYX' ,'GYX_MOTIVO'})
	aAdd(aCampos, {'GYX' ,'GYX_LOCINT'})
	aAdd(aCampos, {'GYX' ,'GYX_HRINT'})
	aAdd(aCampos, {'GYX' ,'GYX_LININT'})
	aAdd(aCampos, {'GYX' ,'GYX_LOCTER'})
	aAdd(aCampos, {'GYX' ,'GYX_CONTRA'})
	aAdd(aCampos, {'GYX' ,'GYX_LINHA'})
	aAdd(aCampos, {'GYX' ,'GYX_IDENT'})
	aAdd(aCampos, {'GYX' ,'GYX_CODSER'})

	//Adicionado para ajuste de dicionário base congelada - inicio
	aAdd(aCampos, {'G99' ,'G99_CODLAN'})
	aAdd(aCampos, {'GI5' ,'GI5_MSBLQL'})
	aAdd(aCampos, {'GIO' ,'GIO_PLAN'})
	aAdd(aCampos, {'GIQ' ,'GIQ_DESLMT'})
	aAdd(aCampos, {'GZN' ,'GZN_ASSOCI'})
	aAdd(aCampos, {'GZN' ,'GZN_ORIGEM'})
	aAdd(aCampos, {'GZN' ,'GZN_VARIAV'})
	aAdd(aCampos, {'GZR' ,'GZR_CODGYG'})
	aAdd(aCampos, {'GZR' ,'GZR_CODGYQ'})
	aAdd(aCampos, {'GZR' ,'GZR_DTREF'})
	aAdd(aCampos, {'GZR' ,'GZR_SITRH'})
	aAdd(aCampos, {'GZR' ,'GZR_TPDIA'})
	
	//Adicionado para ajuste de dicionário base congelada - fim
	aAdd(aCampos, {'GQ8' ,'GQ8_CODLOC'})
	aAdd(aCampos, {'GQ8' ,'GQ8_DESCLO'})
	aAdd(aCampos, {'GQ8' ,'GQ8_QTDTXE'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TOTTXE'})
	aAdd(aCampos, {'GQ8' ,'GQ8_QTDTAR'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TOTTAR'})
	aAdd(aCampos, {'GQ8' ,'GQ8_QTDSEG'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TOTSEG'})
	aAdd(aCampos, {'GQ8' ,'GQ8_QTDPED'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TOTPED'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TOTOUT'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TOTGER'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TIPO'})
	aAdd(aCampos, {'GQ8' ,'GQ8_TIPOAG'})
	aAdd(aCampos, {'GQB' ,'GQB_SERVIC'})
	aAdd(aCampos, {'GQB' ,'GQB_DESCRI'})
	aAdd(aCampos, {'GQZ' ,'GQZ_CODCLI'})
	aAdd(aCampos, {'GQZ' ,'GQZ_CODLOJ'})
	aAdd(aCampos, {'GQZ' ,'GQZ_NOMCLI'})
	aAdd(aCampos, {'GQZ' ,'GQZ_INIVIG'})
	aAdd(aCampos, {'GQZ' ,'GQZ_FIMVIG'})
	aAdd(aCampos, {'GQZ' ,'GQZ_TPDESC'})
	aAdd(aCampos, {'GQZ' ,'GQZ_VALOR '})
	aAdd(aCampos, {'GQI' ,'GQI_CODGI4'})
	aAdd(aCampos, {'GQI' ,'GQI_LOCORI'})
	aAdd(aCampos, {'GQI' ,'GQI_NLOCO'})
	aAdd(aCampos, {'GQI' ,'GQI_LOCDES'})
	aAdd(aCampos, {'GQI' ,'GQI_NLOCD'})
	aAdd(aCampos, {'GQI' ,'GQI_VALOR'})
	aAdd(aCampos, {'GYD' ,'GYD_CODIGO'})
	aAdd(aCampos, {'GYD' ,'GYD_CODLOT'})
	aAdd(aCampos, {'GYD' ,'GYD_CODLOT'})
	aAdd(aCampos, {'GYD' ,'GYD_CODTPD'})
	aAdd(aCampos, {'GYD' ,'GYD_TDDESC'})
	aAdd(aCampos, {'GYD' ,'GYD_VALOR'})
	aAdd(aCampos, {'GYD' ,'GYD_DATA'})
	aAdd(aCampos, {'GYD' ,'GYD_JUSTIF'})
	aAdd(aCampos, {'GYD' ,'GYD_LANCAM'})
	aAdd(aCampos, {'GYD' ,'GYD_CODAGE'})
	aAdd(aCampos, {'GYD' ,'GYD_STATUS'})
	aAdd(aCampos, {'GYD' ,'GYD_CODJUS'})
	aAdd(aCampos, {'GYD' ,'GYD_EMISSO'})
	aAdd(aCampos, {'GYD' ,'GYD_NEMISS'})
	aAdd(aCampos, {'GYD' ,'GYD_AGEDES'})
	aAdd(aCampos, {'GYD' ,'GYD_CODG6X'})

	//tabelas que não precisam de validação de dicionario
	aAdd(aCampos, {'GY9' ,'GY9_CODCAT'})
	aAdd(aCampos, {'GY9' ,'GY9_CODIGO'})
	aAdd(aCampos, {'GY9' ,'GY9_CODORG'})
	aAdd(aCampos, {'GY9' ,'GY9_DESCRI'})
	aAdd(aCampos, {'GYV' ,'GYV_DESCRI'})
	aAdd(aCampos, {'GYV' ,'GYV_MODELO'})
	aAdd(aCampos, {'GYV' ,'GYV_OBSERV'})
	aAdd(aCampos, {'GYY' ,'GYY_CODACS'})
	aAdd(aCampos, {'GYY' ,'GYY_CODVEI'})
	aAdd(aCampos, {'GYY' ,'GYY_DESACS'})
	aAdd(aCampos, {'GYY' ,'GYY_QTDACS'})
	aAdd(aCampos, {'GYS' ,'GYS_CODCAT'})
	aAdd(aCampos, {'GYS' ,'GYS_CODORG'})
	aAdd(aCampos, {'GYS' ,'GYS_COEFI '})
	aAdd(aCampos, {'GYS' ,'GYS_KMMAX '})
	aAdd(aCampos, {'GYS' ,'GYS_KMMIN '})
	aAdd(aCampos, {'GYS' ,'GYS_TIPO  '})
	aAdd(aCampos, {'GYS' ,'GYS_VALOR '})

Return aClone( aCampos )

/*/{Protheus.doc} ExistListSx3
Função valida existencia de campos 
@type function
@author 
@since 03/09/2025
@version 1.0
@param 
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ExistListSx3()
	Local lRetorno  := .F.
	Local aAreaAtu  := GetArea()
	Local nInd1     := 0
	Local nTamX3CPO := Len(SX3->X3_CAMPO)
	Local aLista    := LoadFields()

	dbSelectArea("SX3")
	SX3->(dbSetOrder(2)) 

	For nInd1 := 1 To Len(aLista)

		If SX3->(dbSeek(Padr(aLista[nInd1][2],nTamX3CPO)))
			lRetorno := .T.
			nInd1 := Len(aLista)+1
		EndIf

	Next

	RestArea( aAreaAtu )

	aSize(aLista,0)
	aLista := Nil

Return lRetorno 

/*/{Protheus.doc} CompatSX3Table()
Função para compatibilizar SX3 com tabela fisica
@type function
@author 
@since 03/09/2025
@version 1.0
@param aDelSx9, array, Array contendo os dados a serem deletados
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CompatSX3Table()
    Local cTCBuild  := "TCGetBuild"
    Local aArqUpd   := {}
    Local cTopBuild := ""
	Local nX        := 0
	
    Aadd(aArqUpd,'G56' )	
    Aadd(aArqUpd,'GIJ' )	
    Aadd(aArqUpd,'GIK' )	
    Aadd(aArqUpd,'GIL' )	
    Aadd(aArqUpd,'GIU' )	
    Aadd(aArqUpd,'GIV' )	
    Aadd(aArqUpd,'GIX' )	
    Aadd(aArqUpd,'GIY' )	
    Aadd(aArqUpd,'GIZ' )	
    Aadd(aArqUpd,'GIO' )	
    Aadd(aArqUpd,'GIQ' )
    Aadd(aArqUpd,'GZN' )
    Aadd(aArqUpd,'GZR' )
    Aadd(aArqUpd,'GQ8' )
    Aadd(aArqUpd,'GQB' )
    Aadd(aArqUpd,'GQZ' )
    Aadd(aArqUpd,'GQI' )
    Aadd(aArqUpd,'GYD' )
    Aadd(aArqUpd,'GY9' )
    Aadd(aArqUpd,'GYV' )
    Aadd(aArqUpd,'GYY' )
    Aadd(aArqUpd,'GYS' )
    Aadd(aArqUpd,'G5B' )	
    Aadd(aArqUpd,'GI5' )
    Aadd(aArqUpd,'GI7' )
    Aadd(aArqUpd,'GI9' )
    Aadd(aArqUpd,'GIA' )
    Aadd(aArqUpd,'GIB' )
    Aadd(aArqUpd,'GIF' )
    Aadd(aArqUpd,'GIG' )
    Aadd(aArqUpd,'GIR' )
    Aadd(aArqUpd,'GIS' )
    Aadd(aArqUpd,'GIT' )
    Aadd(aArqUpd,'GIW' )
    Aadd(aArqUpd,'G9P' )
    Aadd(aArqUpd,'GQJ' )
    Aadd(aArqUpd,'GYX' )
    Aadd(aArqUpd,'G99' )

	// Alteração física dos arquivos
	__SetX31Mode( .F. )

	If FindFunction(cTCBuild)
		cTopBuild := &cTCBuild.()
	EndIf

	For nX := 1 To Len( aArqUpd )

		If Select( aArqUpd[nX] ) > 0
			dbSelectArea( aArqUpd[nX] )
			dbCloseArea()
		EndIf

		X31UpdTable( aArqUpd[nX] )

		If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
			TcInternal( 25, "OFF" )
		EndIf

	Next nX

	aSize(aArqUpd,0)
	aArqUpd := 0

Return 
