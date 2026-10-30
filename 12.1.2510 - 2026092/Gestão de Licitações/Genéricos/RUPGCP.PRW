#INCLUDE 'PROTHEUS.CH'
//====================================================================================================================
/*{Protheus.doc} RUP_GCP
Função de compatibilização do release incremental. Esta função é relativa ao módulo Compras Publicas

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author jose.eulalio
@since 22/05/2015
@version P12
*/
//====================================================================================================================
Function RUP_GCP( cVersion, cMode, cRelStart, cRelFinish, cLocaliz )

Local cRelLoop	:= ""
Local nRelease    := 0

#IFDEF TOP 

	If cRelStart < "2210" .And. cRelFinish <= "2410"
		//-- cMode definide se processos devem ser executados para: 1 - Grupo de empresa ; 2 - Grupo + Filial
		If cMode == "2"
			For nRelease := Val( cRelStart ) + 1 to Val( cRelFinish )
				cRelLoop := StrZero( nRelease, 4 ) 	//- Release sendo processado
				DO 	CASE
				   	CASE cRelLoop == "0006" 				//-- Processar apenas no Release 6
						GCP006Ajus()
					CASE cRelLoop == "0016"
						GCP1216Aju()
					CASE cRelLoop == "0017"
						GCP1217Aju()
					CASE cRelLoop == "0023"
						GCP1223Aju()
					CASE cRelLoop == "0027"
						GCP1227Aju()
				ENDCASE
			Next nRelease 
		EndIf
	Endif

#ENDIF

Return NIL

//====================================================================================================================
/*/{Protheus.doc} GCP006Ajus()
Ajuste para release 12.6

@author Leonardo Quintania
@since 29/08/2015
@version P12
@return .T.
/*/
//====================================================================================================================

Static Function GCP006Ajus()

Local aArea     := GetArea()
Local cAliasTmp := GetNextAlias()
Local cQuery    := ""
Local cQryStat	:= ""
Local oCO1CX4	:= FWPreparedStatement():New()

cQuery := " SELECT CO1_FILIAL, CO1_CODEDT, CO1_NUMPRO, CO1_LEI, CO1_ARTIGO, CO1_PARAG, CO1_MODALI, R_E_C_N_O_ REC "
cQuery += " FROM ? CO1 " 
cQuery += " WHERE CO1_ARTIGO <> '' AND CO1_PARAG <> '' AND D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
oCO1CX4:SetQuery(cQuery)

oCO1CX4:SetNumeric(1,RetSqlName("CO1"))

cQryStat := oCO1CX4:GetFixQuery()
MpSysOpenQuery(cQryStat,cAliasTmp)

DbSelectArea("CO1")

DbSelectArea("CX4")
CX4->(DbSetOrder(1))

While (cAliasTmp)->(!Eof())
	If !(CX4->(DbSeek(xFilial("CX4")+(cAliasTmp)->(CO1_CODEDT+CO1_NUMPRO+CO1_MODALI+CO1_LEI+CO1_ARTIGO))))
		If RecLock("CX4",.T.)
			CX4->CX4_FILIAL := (cAliasTmp)->CO1_FILIAL
			CX4->CX4_CODEDT := (cAliasTmp)->CO1_CODEDT
			CX4->CX4_NUMPRO := (cAliasTmp)->CO1_NUMPRO
			CX4->CX4_LEI    := (cAliasTmp)->CO1_LEI
			CX4->CX4_ARTIGO := (cAliasTmp)->CO1_ARTIGO
			CX4->CX4_PARAG  := (cAliasTmp)->CO1_PARAG
			CX4->CX4_MODALI := (cAliasTmp)->CO1_MODALI
			CX4->(MsUnLock())
		EndIf
	Endif

	CO1->(dbGoto((cAliasTmp)->REC))

	If RecLock("CO1",.F.)
		CO1->CO1_ARTIGO	:= ''
		CO1->CO1_PARAG	:= ''
		CO1->(MsUnLock())
	Endif

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(DbCloseArea())

RestArea( aArea )

Return NIL

//====================================================================================================================
/*/{Protheus.doc} GCP1216Aju()
Ajuste para release 12.1.14

@author antenor.silva
@since 24/03/2017
@version P12
/*/
//====================================================================================================================
Function GCP1216Aju()

Local aArea		:= GetArea()
Local cAliasCOX := ""
Local cQuery    := ""
Local cQryStat	:= ""
Local oQRYCOX	:= FWPreparedStatement():New()

DbSelectArea("SX2")
SX2->(DbSetOrder(1))
SX2->(DbSeek("COX"))

If SX2->X2_MODO == "E" .And. SX2->X2_MODOUN	== "E" .And. SX2->X2_MODOEMP == "E"
	If RecLock("SX2",.F.)
		SX2->X2_MODO	:= "C"
		SX2->X2_MODOUN	:= "C"
		SX2->X2_MODOEMP := "C"
		SX2->(MsUnLock())
	Endif

	cAliasCOX := GetNextAlias()

	cQuery := " SELECT COX.COX_FILIAL, COX.R_E_C_N_O_ COXRECNO "
	cQuery += " FROM ? COX" 
	cQuery += " WHERE COX.COX_FILIAL <> '' AND COX.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	oQRYCOX:SetQuery(cQuery)

	oQRYCOX:SetNumeric(1,RetSqlName("COX"))

	cQryStat := oQRYCOX:GetFixQuery()
	MpSysOpenQuery(cQryStat,cAliasCOX)

	DbSelectArea("COX")

	While (cAliasCOX)->(!Eof())
		COX->(dBGoTo((cAliasCOX)->COXRECNO))
		If RecLock("COX",.F.)
			COX->COX_FILIAL := ""
			COX->(MsUnLock())
		Endif
		(cAliasCOX)->(dbSkip())
	Enddo

	(cAliasCOX)->(DbCloseArea())
EndIf

SX3->(dbSetOrder(2)) //-- X3_CAMPO
If SX3->(dbSeek("COM_CODEDT"))
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "V"
	SX3->(MsUnlock())
EndIf

If SX3->(dbSeek("COM_NUMPRO"))
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "V"
	SX3->(MsUnlock())
EndIf

RestArea( aArea )

Return Nil

//====================================================================================================================
/*/{Protheus.doc} GCP1217Aju()
Ajuste para release 12.1.17

@author israel.escorizza
@since 23/11/2017
@version P12
/*/
//====================================================================================================================
Function GCP1217Aju()

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2)) //-- X3_CAMPO
If SX3->(dbSeek("COP_PRCUN")) 
	RecLock("SX3",.F.)
	SX3->X3_VALID := 'Positivo()'
	SX3->(MsUnlock())
EndIf

If SX3->(dbSeek("CPY_QUANT2")) 
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "V"
	SX3->(MsUnlock())
EndIf

If SX3->(dbSeek("CPY_SALDO")) 
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "V"
	SX3->(MsUnlock())
EndIf

If SX3->(dbSeek("CPY_QTDLIC")) 
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "V"
	SX3->X3_WHEN	:= ""
	SX3->(MsUnlock())
EndIf

If SX3->(dbSeek("CPE_DOCMOV")) 
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "V"
	SX3->(MsUnlock())
EndIf

If SX3->(dbSeek("CPI_SALDO")) 
	RecLock("SX3",.F.)
	SX3->X3_VISUAL := "A"
	SX3->(MsUnlock())
EndIf

MigAtaLote()

RestArea(aAreaSX3)
RestArea(aArea)

Return Nil

//====================================================================================================================
/*/{Protheus.doc} MigAtaLote()
Função de migração de campos da tabela CPZ para a tabela CPY, para funcionamento da Ata de Registro de Preço por Lote

@author jose.delmondes
@since 06/07/2017
@version P12
/*/
//====================================================================================================================
Function MigAtaLote()

Local aArea		:= GetArea()
Local aAreaCPY	:= {}
Local cAliasCPZ	:= GetNextAlias()	
Local cQuery    := ""
Local cQryStat	:= ""
Local oQRYCPZ	:= FWPreparedStatement():New()

cQuery := " SELECT	CPZ.CPZ_FILIAL , CPZ.CPZ_NUMATA , CPZ.CPZ_CODPRO , CPZ.CPZ_VLUNIT , CPZ.CPZ_VALATU "
cQuery += " FROM ? CPZ" 
cQuery += " WHERE CPZ.CPZ_STATUS = ? "
cQuery += " AND CPZ.D_E_L_E_T_ = ? "
cQuery := ChangeQuery(cQuery)
oQRYCPZ:SetQuery(cQuery)

oQRYCPZ:SetNumeric(1,RetSqlName("CPZ"))
oQRYCPZ:SetString(2,"5")
oQRYCPZ:SetString(3,Space(1))

cQryStat := oQRYCPZ:GetFixQuery() 
MpSysOpenQuery(cQryStat,cAliasCPZ)

dbSelectArea('CPY')

aAreaCPY := CPY->( GetArea() )

CPY->(dbSetOrder(1))

//Atualiza os preços dos itens de cada licitante vencedor
While (cAliasCPZ)->( !EOF() )
	If CPY->( dbSeek( xFilial( 'CPY' , (cAliasCPZ)->CPZ_FILIAL ) + (cAliasCPZ)->CPZ_NUMATA + (cAliasCPZ)->CPZ_CODPRO ))
		If RecLock('CPY',.F.)
			CPY->CPY_VLUNIT := (cAliasCPZ)->CPZ_VLUNIT
			CPY->CPY_VALATU	:= (cAliasCPZ)->CPZ_VALATU
			CPY->CPY_VLTOT	:= CPY->CPY_QUANT * CPY->CPY_VALATU
			CPY->( msUnlock() )
		Endif
	EndIf 	
	(cAliasCPZ)->( dbSkip() )
EndDo

(cAliasCPZ)->( dbCloseArea() )

RestArea( aAreaCPY )
RestArea( aArea )

Return

//====================================================================================================================
/*/{Protheus.doc} GCP1223Aju()
Ajuste para release 12.1.23

@author janaina.jesus
@since 06/06/2018
@version P12
/*/
//====================================================================================================================
Function GCP1223Aju()

Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2)) //-- X3_CAMPO
If SX3->(dbSeek("CP6_DESCRP")) 
	RecLock("SX3",.F.)
	SX3->X3_RELACAO := 'POSICIONE( "SB1", 1, XFILIAL( "SB1" ) + CP6->CP6_CODPRO, "B1_DESC")'
	SX3->(MsUnlock())
EndIf

RestArea( aAreaSX3 )
RestArea( aArea )

Return

//====================================================================================================================
/*/{Protheus.doc} GCP1227Aju
	Realiza alterações necessarias pro release 12.1.27
@author philipe.pompeu
@since 14/08/2019
/*/
/*Static */
//====================================================================================================================
Function GCP1227Aju()

Local nPos 		:= 0	
Local cChave 	:= ""

If (CPY->((nPos := FieldPos("CPY_OBSERV")) > 0))
	CO2->(DbSetOrder(1))//CO2_FILIAL+CO2_CODEDT+CO2_NUMPRO+CO2_CODPRO
	CPH->(DbSetOrder(2))//CPH_FILIAL+CPH_NUMATA
	CPY->(DbSetOrder(1))//CPY_FILIAL+CPY_NUMATA+CPY_CODPRO
	CPY->(DbGoTop())		
	While (CPY->(!Eof()))			
		If(!Empty(CPY->CPY_OBS) .And. CPH->(DbSeek(CPY->(CPY_FILIAL + CPY_NUMATA))))
			If(Empty(CPH->CPH_FILORI))
				cChave := CPH->CPH_FILIAL
			Else
				cChave := xFilial("CO2", CPH->CPH_FILORI)
			EndIf
			
			cChave += CPH->(CPH_CODEDT + CPH_NUMPRO) + CPY->CPY_CODPRO
							
			If(CO2->(DbSeek(cChave) .And. !Empty(CO2_OBS)))					
				RecLock("CPY", .F.)				
				CPY->(FieldPut(nPos, CO2->CO2_OBS)) //Transfere o valor do campo CO2_OBS p/ CPY_OBSERV(M) 
				CPY->(MsUnlock())
			EndIf				
		EndIf
		CPY->(dbSkip())
	EndDo
EndIf

Return
