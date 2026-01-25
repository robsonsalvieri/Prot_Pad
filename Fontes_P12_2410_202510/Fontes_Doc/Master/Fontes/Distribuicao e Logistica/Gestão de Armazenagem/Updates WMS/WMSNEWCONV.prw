#INCLUDE "PROTHEUS.CH" 

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} WMSNEWCONV
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  18/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function WMSNEWCONV( cEmpAmb, cFilAmb )
Local aSay      := {}
Local aButton   := {}
Local aMarcadas := {}
Local cTitulo   := "ATUALIZAÇÃO DE TABELAS SBF e SBK"
Local cDesc1    := "Esta rotina tem como função realizar a conversão do WMS ATUAL para o WMS NOVO "
Local cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros "
Local cDesc3    := "usuários ou jobs utilizando o sistema. É EXTREMAMENTE recomendavél que se faça um "
Local cDesc4    := "BACKUP da BASE DE DADOS antes desta atualização, para que caso "
Local cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado. "
Local cDesc6    := "Esta rotina apaga os dados das tabelas SBF e SBK e gera dados para D14 e D15 "
Local cDesc7    := "respectivamente. O BACKUP pode considerar esses dados."
Local lOk       := .F.
Local lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

	TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top

	__cInterNet := NIL
	__lPYME     := .F.
	
	Set Dele On
	
	// Mensagens de Tela Inicial
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )
	aAdd( aSay, cDesc4 )
	aAdd( aSay, cDesc5 )
	aAdd( aSay, cDesc6 )
	aAdd( aSay, cDesc7 )

	// Botoes Tela Inicial
	aAdd( aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
	aAdd( aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

	If lAuto
		lOk := .T.
	Else
		FormBatch(  cTitulo,  aSay,  aButton )
	EndIf

	If lOk
		If lAuto
			aMarcadas := { cEmpAmb }
		Else
			aMarcadas := EscEmpresa()
		EndIf

		If Len( aMarcadas ) > 0
			If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários?", cTitulo )
				oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde...", .F. )
				oProcess:Activate()
			Else
				MsgStop( "Atualização não realizada.", "WMSNEWCONV" )
			EndIf
		Else
			MsgStop( "Nenhuma empresa foi selecionada! A atualização não será realizada.", "WMSNEWCONV" )
		EndIf
	EndIf

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  18/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local aInfo     := {}
Local cFile     := ""
Local cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cTexto    := ""
Local lOpen     := .F.
Local lRet      := .T.
Local nI        := 0
Local nJ        := 0
Local nPos      := 0
Local oDlg      := NIL
Local oFont     := NIL
Local oMemo     := NIL
Local lWmsNew   := .F.
Local cDadosProd:= ""
Local cQuery    := ""
Local cAliasQry := ""
Local nRowCount := 0
Local aAllGroup := {}
Local aAllFil   := {}
Local cZona     := ''
Local cEstNUnit := ''
Local cEstUnit  := ''
Local cAliasNNR := ''
Local cAliasDC8 := ''
Local lGravaD14 := .T.
Local lErroSBE  := .F.
//regras extraídas dos fontes WMSDTCEstoqueEndereco e WMSXFuna
Local oTipUnit  := nil
Local cTipUnit  := ''

If MyOpenSM0(.T.)

	aAllGroup := FWAllGrpCompany()

	For nI := 1 To Len( aAllGroup )

		If aScan( aMarcadas, aAllGroup[nI] ) <= 0
			Loop
		EndIf

		If !( lOpen := MyOpenSM0(.F.,aAllGroup[nI]) )
			MsgStop( "Atualização da empresa " + aAllGroup[nI] + " não efetuada." )
			Exit
		EndIf

		aAllFil := FWAllFilial(/*cCompany*/,/*cUnitBusiness*/,aAllGroup[nI],/*lOnlyCode*/.F.)

		For nJ := 1 To Len ( aAllFil )

			RpcSetType( 3 )
			RpcSetEnv( aAllGroup[nI], aAllFil[nJ] )
			
			cDadosProd:= SuperGetMV("MV_ARQPROD",.F.,"SB1")
			lWmsNew := SuperGetMv("MV_WMSNEW",.F.,.F.)
			lErroSBE := .F.

			AutoGrLog( Replicate( "-", 124 ) )
			AutoGrLog( Replicate( " ", 124 ) )

			If !lWmsNew
				AutoGrLog( "O parâmetro MV_WMSNEW precisa estar ativo!" )
				lRet := .F.
			EndIf

			If ChkMovSDB()
				AutoGrLog( "Existem movimentos SDB que não foram finalizados!" )
				lRet := .F.			
			EndIf

			/*Determina a zona a ser usada nos endereços que não possuam zona informada.
			 *Zona é obrigatória para o endereçamento.
			 */
			DC4->(dbSetOrder(1))
			DC4->(dbGoTop())			
			cZona := DC4->DC4_CODZON

			/*Se houver armazém  unitizado, efetua a leitura de uma estrutura unitizada.
			 *Estrutura é obrigatória para o endereçamento.
			 */
			cAliasNNR := GetNextAlias()

			BeginSql Alias cAliasNNR
				SELECT NNR.NNR_FILIAL 
				FROM %Table:NNR% NNR
				WHERE NNR.NNR_FILIAL = %xFilial:NNR%
				AND NNR.NNR_AMZUNI = '1'
				AND NNR.%NotDel%
			EndSql
			If !(cAliasNNR)->(Eof())
				cAliasDC8 := GetNextAlias()
				BeginSql Alias cAliasDC8
					SELECT DC8_CODEST 
					FROM %Table:DC8% DC8
					WHERE DC8_FILIAL = %xFilial:DC8% 
					AND DC8_STATUS = '1'
					AND DC8.%NotDel%
					ORDER BY DC8_FILIAL, DC8_CODEST
				EndSql
				
				cEstUnit := (cAliasDC8)->DC8_CODEST
				(cAliasDC8)->(dbCloseArea())
			EndIf

			(cAliasNNR)->(dbCloseArea())

			/*Se houver armazém não unitizado, efetua a leitura de uma estrutura não unitizada.
			 *Estrutura é obrigatória para o endereçamento.
			 */
			cAliasNNR := GetNextAlias()

			BeginSql Alias cAliasNNR
				SELECT NNR.NNR_FILIAL 
				FROM %Table:NNR% NNR
				WHERE NNR.NNR_FILIAL = %xFilial:NNR%
				AND NNR.NNR_AMZUNI = '2'
				AND NNR.%NotDel%
			EndSql
			If !(cAliasNNR)->(Eof())
				cAliasDC8 := GetNextAlias()
				BeginSql Alias cAliasDC8
					SELECT DC8_CODEST 
					FROM %Table:DC8% DC8
					WHERE DC8_FILIAL = %xFilial:DC8% 
					AND DC8_STATUS = '2'
					AND DC8.%NotDel%
					ORDER BY DC8_FILIAL, DC8_CODEST
				EndSql
				
				cEstNUnit := (cAliasDC8)->DC8_CODEST
				(cAliasDC8)->(dbCloseArea())
			EndIf

			(cAliasNNR)->(dbCloseArea())
		
			//Determina o tipo de unitizador padrão
			oTipUnit := WMSDTCUnitizadorArmazenagem():New()
			oTipUnit:FindPadrao()
			cTipUnit := oTipUnit:GetTipUni()
			oTipUnit:Destroy()
			
			If !lRet 
				Exit
			EndIf
			
			If lRet
				lMsFinalAuto := .F.
				lMsHelpAuto  := .F.
				
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "LOG DA ATUALIZAÇÃO DA BASE" )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( " " )
				AutoGrLog( " Dados Ambiente" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
				AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
				AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
				AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
				AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
				AutoGrLog( " Environment........: " + GetEnvServer()  )
				AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
				AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
				AutoGrLog( " Versão.............: " + GetVersao(.T.) )
				AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
				AutoGrLog( " Computer Name......: " + GetComputerName() )

				aInfo := GetUserInfo()
				If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
					AutoGrLog( " " )
					AutoGrLog( " Dados Thread" )
					AutoGrLog( " --------------------" )
					AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
					AutoGrLog( " Estação............: " + aInfo[nPos][2] )
					AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
					AutoGrLog( " Environment........: " + aInfo[nPos][6] )
					AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
				EndIf
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( " " )

				If !lAuto
					AutoGrLog( Replicate( "-", 124 ) )
					AutoGrLog( "Empresa : " + FWGrpCompany() + "/" + FWGrpName() + CRLF )
				EndIf
				
				//Força a criação das tabelas no banco de dados físico
				//Manter esses comandos para evitar erro ao selecionar a tabela
				RetSqlName("D05")
				RetSqlName("D11")
				RetSqlName("D12")
				RetSqlName("DCR")
				RetSqlName("D13")
				RetSqlName("D14")
				RetSqlName("D15")
				RetSqlName("D0G")
				RetSqlName("D0F")
				RetSqlName("D0I")
				RetSqlName("D0J")
				RetSqlName("D0H")
				RetSqlName("D0K")
				RetSqlName("DH1")
				RetSqlName("CBN")
				RetSqlName("SBK")
				
				oProcess:SetRegua1( 3 )
				oProcess:IncRegua1( "Conversão SBF - Saldos por Endereço" )
					
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "INICIO CONVERSÃO SBF - SALDOS POR ENDEREÇO" )
				AutoGrLog( Replicate( " ", 124 ) )
					
				cQuery := " SELECT SBF.BF_LOCAL,"
				cQuery +=        " SBF.BF_LOCALIZ,"
				cQuery +=        " SBF.BF_PRODUTO,"
				cQuery +=        " SB8.B8_LOTECTL,"
				cQuery +=        " SB8.B8_NUMLOTE,"
				cQuery +=        " SBF.BF_NUMSERI,"
				cQuery +=        " SB8.B8_DTVALID,"
				cQuery +=        " SB8.B8_DFABRIC,"
				cQuery +=        " SBE.BE_ESTFIS,"
				cQuery +=        " SBE.BE_PRIOR,"
				cQuery +=        " SBE.BE_CODZON,"
				cQuery +=        " SBE.R_E_C_N_O_ SBERECNO,"
				cQuery +=        " SBF.BF_QUANT,"
				cQuery +=        " SBF.BF_QTSEGUM,"
				cQuery +=        " SBF.R_E_C_N_O_ SBFRECNO,"
				cQuery +=        " NNR.NNR_AMZUNI"
				cQuery +=   " FROM "+RetSqlName("SBF")+" SBF"
				cQuery +=  " INNER JOIN "+RetSqlName("SBE")+" SBE"
				cQuery +=     " ON SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
				cQuery +=    " AND SBE.BE_LOCAL   = SBF.BF_LOCAL"
				cQuery +=    " AND SBE.BE_LOCALIZ = SBF.BF_LOCALIZ"
				cQuery +=    " AND SBE.D_E_L_E_T_ = ' '"
				cQuery +=  " INNER JOIN " + RetSqlName("NNR") + " NNR "
				cQuery +=    "  ON NNR.NNR_FILIAL = '" + xFilial('NNR')+"'"
				cQuery +=    " AND NNR.NNR_CODIGO = SBF.BF_LOCAL"
				cQuery +=    " AND NNR.D_E_L_E_T_ = ' '"
				cQuery +=   " LEFT JOIN "+RetSqlName("SB8")+" SB8"
				cQuery +=     " ON SB8.B8_FILIAL  = '"+xFilial("SB8")+"'"
				cQuery +=    " AND SB8.B8_PRODUTO = SBF.BF_PRODUTO"
				cQuery +=    " AND SB8.B8_LOCAL   = SBF.BF_LOCAL"
				cQuery +=    " AND SB8.B8_LOTECTL = SBF.BF_LOTECTL"
				cQuery +=    " AND SB8.B8_NUMLOTE = SBF.BF_NUMLOTE"
				cQuery +=    " AND SB8.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE SBF.BF_FILIAL  = '"+xFilial("SBF")+"'"
				cQuery +=    " AND SBF.BF_QUANT > 0"
				cQuery +=    " AND SBF.D_E_L_E_T_ = ' '"
				If cDadosProd == 'SBZ'
					cQuery += " AND (EXISTS (SELECT 1"
					cQuery +=                " FROM "+RetSqlName("SBZ")+" SBZ"
					cQuery +=               " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
					cQuery +=                 " AND SBZ.BZ_COD     = SBF.BF_PRODUTO"
					cQuery +=                 " AND SBZ.BZ_LOCALIZ IN (' ','S')"
					cQuery +=                 " AND SBZ.BZ_CTRWMS  IN (' ','1')"
					cQuery +=                 " AND SBZ.D_E_L_E_T_ = ' ')"
					cQuery +=      " OR ( NOT EXISTS (SELECT 1"
					cQuery +=                         " FROM "+RetSqlName("SBZ")+" SBZ"
					cQuery +=                        " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
					cQuery +=                          " AND SBZ.BZ_COD     = SBF.BF_PRODUTO"
					cQuery +=                          " AND SBZ.BZ_LOCALIZ IN (' ','S')"
					cQuery +=                          " AND SBZ.BZ_CTRWMS  IN (' ','1')"
					cQuery +=                          " AND SBZ.D_E_L_E_T_ = ' ')"
				EndIf
				cQuery +=           " AND EXISTS (SELECT 1"
				cQuery +=                         " FROM "+RetSqlName("SB5")+" SB5"
				cQuery +=                        " INNER JOIN "+RetSqlName("SB1")+" SB1"
				cQuery +=                           " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
				cQuery +=                          " AND SB1.B1_COD = SB5.B5_COD"
				cQuery +=                          " AND SB1.B1_LOCALIZ = 'S'"
				cQuery +=                          " AND SB1.D_E_L_E_T_ = ' '"
				cQuery +=                        " WHERE SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
				cQuery +=                          " AND SB5.B5_COD = SBF.BF_PRODUTO"
				cQuery +=                          " AND SB5.B5_CTRWMS = '1'"
				cQuery +=                          " AND SB5.D_E_L_E_T_ = ' ')"
				If cDadosProd == 'SBZ'
					cQuery +="))"
				EndIf
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

				tcSetField(cAliasQry,'B8_DTVALID','D')
				tcSetField(cAliasQry,'B8_DFABRIC','D')
				tcSetField(cAliasQry,'BF_QUANT'  ,'N',TamSx3("BF_QUANT")[1],TamSx3("BF_QUANT")[2])
				tcSetField(cAliasQry,'BF_QTSEGUM','N',TamSx3("BF_QTSEGUM")[1],TamSx3("BF_QTSEGUM")[2])

				nRowCount := 0
				(cAliasQry)->(dbEval({|| nRowCount++ }))

				oProcess:SetRegua2( nRowCount )
				AutoGrLog( "Seleção SBF aplicada: "+cQuery )
				AutoGrLog( "Registros SBF encontrados: "+AllTrim(Str(nRowCount)) )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "CRIAÇÃO D14 - SALDO POR ENDEREÇO WMS" )
				AutoGrLog( Replicate( " ", 124 ) )

				Begin Transaction
				
				DbSelectArea('D14')
				
				(cAliasQry)->(dbGoTop())
				Do While (cAliasQry)->(!Eof())
					lGravaD14 := .T.

					//Se uma das 2 informações estiver vazia, deve gravá-la
					If Empty((cAliasQry)->BE_CODZON) .Or. Empty((cAliasQry)->BE_ESTFIS)
						
						SBE->(dbGoTo((cAliasQry)->SBERECNO))
						RecLock('SBE', .F.)
						
						//Grava a informação se estiver vazia e houver zona
						If Empty((cAliasQry)->BE_CODZON)
							If !Empty(AllTrim(cZona))
								SBE->BE_CODZON := cZona
								AutoGrLog("Endereço " + AllTrim((cAliasQry)->BF_LOCALIZ) + " com zona em branco. Definido automaticamente o valor " + AllTrim(cZona) + " para permitir a conversão.")
							Else 
								lGravaD14 := .F.
								lErroSBE  := .T.
								AutoGrLog("Registro D14 não criado. Endereço " + AllTrim((cAliasQry)->BF_LOCALIZ) + " sem zona informada e não há zonas cadastradas para a filial. Ajuste o cadastro e execute novamente a conversão.")
							EndIf
						EndIf

						If Empty((cAliasQry)->BE_ESTFIS)
							//Grava a informação se estiver vazia e houver estrutura unitizada/não unitizada
							If (cAliasQry)->NNR_AMZUNI == '1'
								If !Empty(Alltrim(cEstUnit))
									SBE->BE_ESTFIS := cEstUnit
									AutoGrLog("Endereço " + AllTrim((cAliasQry)->BF_LOCALIZ) + " com estrutura física em branco. Definido automaticamente o valor " + AllTrim(cEstUnit) + " para permitir a conversão.")
								Else
									lGravaD14 := .F.
									lErroSBE  := .T.
									AutoGrLog("Registro D14 não criado. Endereço " + AllTrim((cAliasQry)->BF_LOCALIZ) + " sem estrutura informada e não há estruturas unitizadas cadastradas para a filial. Ajuste o cadastro e execute novamente a conversão.")
								EndIf
							Else
								If !Empty(Alltrim(cEstNUnit))
									SBE->BE_ESTFIS := cEstNUnit
									AutoGrLog("Endereço " + AllTrim((cAliasQry)->BF_LOCALIZ) + " com estrutura física em branco. Definido automaticamente o valor " + AllTrim(cEstNUnit) + " para permitir a conversão.")
								Else
									lGravaD14 := .F.
									lErroSBE  := .T.
									AutoGrLog("Registro D14 não criado. Endereço " + AllTrim((cAliasQry)->BF_LOCALIZ) + " sem estrutura informada e não há estruturas não unitizadas cadastradas para a filial. Ajuste o cadastro e execute novamente a conversão.")
								EndIf
							EndIf
						EndIf

						SBE->(MsUnlock())
					EndIf

					If lGravaD14
						RecLock("D14",.T.)
						D14->D14_FILIAL := xFilial("D14")
						D14->D14_LOCAL  := (cAliasQry)->BF_LOCAL
						D14->D14_ENDER  := (cAliasQry)->BF_LOCALIZ
						D14->D14_PRDORI := (cAliasQry)->BF_PRODUTO
						D14->D14_PRODUT := (cAliasQry)->BF_PRODUTO
						D14->D14_LOTECT := (cAliasQry)->B8_LOTECTL
						D14->D14_NUMLOT := (cAliasQry)->B8_NUMLOTE
						D14->D14_NUMSER := (cAliasQry)->BF_NUMSERI
						D14->D14_DTVALD := (cAliasQry)->B8_DTVALID
						D14->D14_DTFABR := (cAliasQry)->B8_DFABRIC
						D14->D14_ESTFIS := (cAliasQry)->BE_ESTFIS
						D14->D14_PRIOR  := (cAliasQry)->BE_PRIOR
						D14->D14_QTDEST := (cAliasQry)->BF_QUANT
						D14->D14_QTDES2 := (cAliasQry)->BF_QTSEGUM
					
						//Se for armazém unitizado, determina o unitizador para o produto no endereço.
						If (cAliasQry)->NNR_AMZUNI == '1'
							D14->D14_IDUNIT := WmsGerUnit(,,,,cTipUnit)
							If HasCodUni()
								D14->D14_CODUNI := cTipUnit
							EndIf
						EndIf

						D14->(MsUnlock())

						AutoGrLog( "Registro D14 criado: "+AllTrim(Str(D14->(Recno()))) )

						SBF->(dbGoTo((cAliasQry)->SBFRECNO))
						RecLock("SBF",.F.)
						SBF->(dbDelete())
						SBF->(MsUnLock())

						oProcess:IncRegua2( "Registro SBF eliminado: "+AllTrim(Str((cAliasQry)->SBFRECNO)) )
						AutoGrLog( "Registro SBF eliminado: "+AllTrim(Str((cAliasQry)->SBFRECNO)) )
					EndIf

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())

				AutoGrLog( Replicate( " ", 124 ) )
				If lErroSBE
					AutoGrLog( "Existem endereços com zona ou estrutura de armazenagem não informados. Não existem zonas cadastradas e/ou estruturas de armazenagem cadastradas para definição automática dessas informações nesses endereços. ")
					AutoGrLog( "Ajuste o cadastro desses endereços ou inclua uma zona, uma estrutura de armazenagem não unitizada e uma estrutura de armazenagem unitizada (se existirem armazéns unitizados) para que sejam automaticamente definidos nos endereços durante o processo de conversão.")
					AutoGrLog( "Após, execute novamente o programa para conversão das informações não processadas." )
					AutoGrLog( Replicate( " ", 124 ) )
				EndIf
				AutoGrLog( "FIM CONVERSÃO SBF - SALDOS POR ENDEREÇO" )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( Replicate( "-", 124 ) )

				oProcess:IncRegua1( "Conversão SBK - Saldos Iniciais por Endereço" )

				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "INICIO CONVERSÃO SBK - SALDOS INICIAIS POR ENDEREÇO" )
				AutoGrLog( Replicate( " ", 124 ) )

				cQuery := " SELECT SBK.BK_COD,"
				cQuery +=        " SBK.BK_LOCAL,"
				cQuery +=        " SBK.BK_DATA,"
				cQuery +=        " SBK.BK_QINI,"
				cQuery +=        " SBK.BK_QISEGUM,"
				cQuery +=        " SBK.BK_LOTECTL,"
				cQuery +=        " SBK.BK_NUMLOTE,"
				cQuery +=        " SBK.BK_LOCALIZ,"
				cQuery +=        " SBK.BK_NUMSERI,"
				cQuery +=        " SBE.BE_PRIOR,"
				cQuery +=        " SBK.R_E_C_N_O_ SBKRECNO"
				cQuery +=   " FROM "+RetSqlName("SBK")+" SBK"
				cQuery +=  " INNER JOIN "+RetSqlName("SBE")+" SBE"
				cQuery +=     " ON SBE.BE_FILIAL  = '"+xFilial("SBE")+"'"
				cQuery +=    " AND SBE.BE_LOCAL   = SBK.BK_LOCAL"
				cQuery +=    " AND SBE.BE_LOCALIZ = SBK.BK_LOCALIZ"
				cQuery +=    " AND SBE.D_E_L_E_T_ = ' '"
				cQuery +=  " WHERE SBK.BK_FILIAL  = '"+xFilial("SBK")+"'"
				cQuery +=    " AND SBK.BK_DATA    = '"+DTOS(GetMv("MV_ULMES"))+"'"
				cQuery +=    " AND SBK.D_E_L_E_T_ = ' '"
				If cDadosProd == 'SBZ'
					cQuery += " AND (EXISTS (SELECT 1"
					cQuery +=                " FROM "+RetSqlName("SBZ")+" SBZ"
					cQuery +=               " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
					cQuery +=                 " AND SBZ.BZ_COD     = SBK.BK_COD"
					cQuery +=                 " AND SBZ.BZ_LOCALIZ IN (' ','S')"
					cQuery +=                 " AND SBZ.BZ_CTRWMS  IN (' ','1')"
					cQuery +=                 " AND SBZ.D_E_L_E_T_ = ' ')"
					cQuery +=      " OR ( NOT EXISTS (SELECT 1"
					cQuery +=                         " FROM "+RetSqlName("SBZ")+" SBZ"
					cQuery +=                        " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'"
					cQuery +=                          " AND SBZ.BZ_COD     = SBK.BK_COD"
					cQuery +=                          " AND SBZ.BZ_LOCALIZ IN (' ','S')"
					cQuery +=                          " AND SBZ.BZ_CTRWMS  IN (' ','1')"
					cQuery +=                          " AND SBZ.D_E_L_E_T_ = ' ')"
				EndIf
				cQuery +=           " AND EXISTS (SELECT 1"
				cQuery +=                         " FROM "+RetSqlName("SB5")+" SB5"
				cQuery +=                        " INNER JOIN "+RetSqlName("SB1")+" SB1"
				cQuery +=                           " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
				cQuery +=                          " AND SB1.B1_COD = SB5.B5_COD"
				cQuery +=                          " AND SB1.B1_LOCALIZ = 'S'"
				cQuery +=                          " AND SB1.D_E_L_E_T_ = ' '"
				cQuery +=                        " WHERE SB5.B5_FILIAL  = '"+xFilial("SB5")+"'"
				cQuery +=                          " AND SB5.B5_COD = SBK.BK_COD"
				cQuery +=                          " AND SB5.B5_CTRWMS = '1'"
				cQuery +=                          " AND SB5.D_E_L_E_T_ = ' ')"
				If cDadosProd == 'SBZ'
					cQuery +="))"
				EndIf
				cQuery := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

				tcSetField(cAliasQry,'BK_DATA'   ,'D')
				tcSetField(cAliasQry,'BK_QINI'   ,'N',TamSx3("BK_QINI")[1],TamSx3("BK_QINI")[2])
				tcSetField(cAliasQry,'BK_QISEGUM','N',TamSx3("BK_QISEGUM")[1],TamSx3("BK_QISEGUM")[2])

				nRowCount := 0
				(cAliasQry)->(dbEval({|| nRowCount++ }))

				oProcess:SetRegua2( nRowCount )
				AutoGrLog( "Seleção SBK aplicada: "+cQuery )
				AutoGrLog( "Registros SBK encontrados: "+AllTrim(Str(nRowCount)) )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "CRIAÇÃO D15 - SALDOS INICIAIS ENDEREÇO WMS" )
				AutoGrLog( Replicate( " ", 124 ) )
				
				dbSelectArea("D15")
				
				(cAliasQry)->(dbGoTop())
				Do While (cAliasQry)->(!Eof())
					RecLock("D15",.T.)
					D15->D15_FILIAL := xFilial("D15")
					D15->D15_PRODUT := (cAliasQry)->BK_COD
					D15->D15_LOCAL  := (cAliasQry)->BK_LOCAL
					D15->D15_DATA   := (cAliasQry)->BK_DATA
					D15->D15_QINI   := (cAliasQry)->BK_QINI
					D15->D15_QISEGU := (cAliasQry)->BK_QISEGUM
					D15->D15_LOTECT := (cAliasQry)->BK_LOTECTL
					D15->D15_NUMLOT := (cAliasQry)->BK_NUMLOTE
					D15->D15_ENDER  := (cAliasQry)->BK_LOCALIZ
					D15->D15_NUMSER := (cAliasQry)->BK_NUMSERI
					D15->D15_PRIOR  := (cAliasQry)->BE_PRIOR
					D15->D15_PRDORI := (cAliasQry)->BK_COD
					D15->(MsUnlock())

					AutoGrLog( "Registro D15 criado: "+AllTrim(Str(D15->(Recno()))) )

					SBK->(dbGoTo((cAliasQry)->SBKRECNO))
					RecLock("SBK",.F.)
					SBK->(dbDelete())
					SBK->(MsUnLock())

					oProcess:IncRegua2( "Registro SBK eliminado: "+AllTrim(Str((cAliasQry)->SBKRECNO)) )
					AutoGrLog( "Registro SBK eliminado: "+AllTrim(Str((cAliasQry)->SBKRECNO)) )

					(cAliasQry)->(dbSkip())
				EndDo
				(cAliasQry)->(dbCloseArea())
				
				End Transaction

				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "FIM CONVERSÃO SBK - SALDOS INICIAIS POR ENDEREÇO" )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( Replicate( "-", 124 ) )

				//Processa inclusão de registros nas tabelas de ligação D0H, D0I e D0J.
				ProcExp()
				
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
				AutoGrLog( Replicate( "-", 124 ) )
			EndIf

			RpcClearEnv()

		Next nJ

	Next nI

	If !lAuto
		cTexto := LeLog()

		Define Font oFont Name "Mono AS" Size 5, 12

		Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

		Activate MsDialog oDlg Center
	EndIf

Else
	lRet := .F.
EndIf

Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()
//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local aRet      := {}
Local aVetor    := {}
Local cMascEmp  := "??"
Local cVar      := ""
Local lChk      := .F.
Local lTeveMarc := .F.
Local oNo       := LoadBitmap( GetResources(), "LBNO" )
Local oOk       := LoadBitmap( GetResources(), "LBOK" )
Local oDlg, oChkMar, oLbx, oMascEmp, oSay
Local oButDMar, oButInv, oButMarc, oButOk, oButCanc
Local aMarcadas := {}
Local aAllGroup := {}
Local nI        := 0

If !MyOpenSM0(.T.)
	Return aRet
EndIf

aAllGroup := FWAllGrpCompany()

For nI := 1 To Len( aAllGroup )
	aAdd(  aVetor, { .F., aAllGroup[nI], "", FWGrpName(aAllGroup[nI]), "" } )
Next nI

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"
oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip :=  oDlg:cTitle
oLbx:lHScroll := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

Return  aRet
//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()
Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()
Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local nI := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, aVetor[nI][2] )
	EndIf
Next nI

Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()
Return NIL
//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()
Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  18/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared,cGrpCompany)
Local lOpen := .F.
Local nLoop := 0

	For nLoop := 1 To 20

		If lShared
			OpenSM0(cGrpCompany)
		Else
			OpenSM0Excl(cGrpCompany)
		EndIf

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			Exit
		EndIf

		Sleep( 500 )

	Next nLoop

	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela de empresas (SM0)" + Iif(lShared,"."," de forma exclusiva."))
	EndIf

Return lOpen

//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  18/01/2016
@obs    Gerado por EXPORDIC - V.5.1.0.0 EFS / Upd. V.4.20.15 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()
	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 124 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 124 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()
Return cRet
/////////////////////////////////////////////////////////////////////////////
Static Function ChkMovSDB()
Local aAreaAnt := GetArea()
Local lRet := .F.
Local cQuery := ""
Local cAliasQry := ""

	// Realiza uma busca nos movimentos WMS e verificando se existe algum que não tenha finalizado
	cQuery := " SELECT 1 FROM "+RetSqlName("SDB")+" SDB"
	cQuery +=  " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
	cQuery +=    " AND SDB.DB_ESTORNO <> 'S'"
	cQuery +=    " AND SDB.DB_ATUEST = 'N'"
	cQuery +=    " AND SDB.DB_STATUS IN ('2','3','4')"
	cQuery +=    " AND SDB.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(!Eof())
		lRet := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())

	RestArea(aAreaAnt)
Return lRet

Static Function ProcExp()
Local lRet      := .T.
Local aAreaAnt  := GetArea()
Local cQuery    := ""
Local cAliasQry := Nil
	// Cria D0H
	cQuery := " SELECT DCF.DCF_ID,"
	cQuery +=        " D01.D01_CODEXP"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " INNER JOIN "+RetSqlName('D01')+" D01"
	cQuery +=     " ON D01.D01_FILIAL = '"+xFilial("D01")+"'"
	cQuery +=    " AND D01.D01_CARGA  = DCF.DCF_CARGA"
	cQuery +=    " AND D01.D01_PEDIDO = DCF.DCF_DOCTO"
	cQuery +=    " AND D01.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCF.DCF_ORIGEM = 'SC9'"
	cQuery +=    " AND DCF.DCF_STSERV = '3'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS (SELECT D0H.D0H_IDDCF"
	cQuery +=                      " FROM "+RetSqlName('D0H')+" D0H"
	cQuery +=                     " WHERE D0H.D0H_FILIAL = '"+xFilial("D0H")+"'"
	cQuery +=                       " AND D0H.D0H_CODEXP = D01.D01_CODEXP"
	cQuery +=                       " AND D0H.D0H_IDDCF  = DCF.DCF_ID"
	cQuery +=                       " AND D0H.D_E_L_E_T_ =  ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		Reclock("D0H",.T.)
		D0H->D0H_FILIAL := xFilial('D0H')
		D0H->D0H_CODEXP := (cAliasQry)->D01_CODEXP
		D0H->D0H_IDDCF  := (cAliasQry)->DCF_ID
		D0H->(MsUnlock())
		D0H->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	// Cria D0I
	cQuery := " SELECT DCF.DCF_ID,"
	cQuery +=        " DCS.DCS_CODMNT"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " INNER JOIN "+RetSqlName('DCS')+" DCS"
	cQuery +=     " ON DCS.DCS_FILIAL = '"+xFilial("DCS")+"'"
	cQuery +=    " AND DCS.DCS_CARGA  = DCF.DCF_CARGA"
	cQuery +=    " AND DCS.DCS_PEDIDO = DCF.DCF_DOCTO"
	cQuery +=    " AND DCS.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCF.DCF_ORIGEM = 'SC9'"
	cQuery +=    " AND DCF.DCF_STSERV = '3'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS (SELECT D0I.D0I_IDDCF"
	cQuery +=                      " FROM "+RetSqlName('D0I')+" D0I"
	cQuery +=                     " WHERE D0I_FILIAL = '"+xFilial("D0I")+"'"
	cQuery +=                       " AND D0I_CODMNT = DCS.DCS_CODMNT"
	cQuery +=                       " AND D0I_IDDCF  = DCF.DCF_ID"
	cQuery +=                       " AND D0I.D_E_L_E_T_ =  ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		Reclock("D0I",.T.)
		D0I->D0I_FILIAL := xfilial("D0I")
		D0I->D0I_CODMNT := (cAliasQry)->DCS_CODMNT
		D0I->D0I_IDDCF  := (cAliasQry)->DCF_ID
		D0I->(MsUnlock())
		D0I->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	// Cria D0J
	cQuery := " SELECT DCF.DCF_ID,"
	cQuery +=        " D0D.D0D_CODDIS"
	cQuery +=   " FROM "+RetSqlName('DCF')+" DCF"
	cQuery +=  " INNER JOIN "+RetSqlName('D0D')+" D0D"
	cQuery +=     " ON D0D.D0D_FILIAL = '"+xFilial("D0D")+"'"
	cQuery +=    " AND D0D.D0D_CARGA  = DCF.DCF_CARGA"
	cQuery +=    " AND D0D.D0D_PEDIDO = DCF.DCF_DOCTO"
	cQuery +=    " AND D0D.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
	cQuery +=    " AND DCF.DCF_ORIGEM = 'SC9'"
	cQuery +=    " AND DCF.DCF_STSERV = '3'"
	cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
	cQuery +=    " AND NOT EXISTS (SELECT D0J.D0J_IDDCF"
	cQuery +=                      " FROM "+RetSqlName('D0J')+" D0J"
	cQuery +=                     " WHERE D0J.D0J_FILIAL = '"+xFilial("D0J")+"'"
	cQuery +=                       " AND D0J.D0J_CODDIS = D0D.D0D_CODDIS"
	cQuery +=                       " AND D0J.D0J_IDDCF  = DCF.DCF_ID"
	cQuery +=                       " AND D0J.D_E_L_E_T_ =  ' ')"
	cQuery := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	While (cAliasQry)->(!EoF())
		Reclock("D0J",.T.)
		D0J->D0J_FILIAL := xFilial("D0J")
		D0J->D0J_CODDIS := (cAliasQry)->D0D_CODDIS
		D0J->D0J_IDDCF  := (cAliasQry)->DCF_ID
		D0J->(MsUnlock())
		D0J->(dbCommit())
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	// Restaura Area
	RestArea(aAreaAnt)
Return lRet

/*Verifica se o campo existe. Tratamento baseado na função WmsX312118 e feito desta maneira pois
 * o programa é executado por fora do menu e não tem a leitura das tabelas no início da execução.
 */
Static lHasCodUni := nil
Function HasCodUni()
	If lHasCodUni = nil
		lHasCodUni := D14->(FieldPos('D14_CODUNI')) > 0
	EndIf
Return lHasCodUni
