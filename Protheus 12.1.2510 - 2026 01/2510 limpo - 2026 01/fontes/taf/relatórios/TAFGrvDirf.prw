#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TAFGRVDIRF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TafGrvDIRF
@type			function
@description	Função para gravar informações da DIRF na tabela intermediária
@Author			Denis R de Oliveira
@Since			10/11/2025
@Version		1.0
@param 			aAnalitico, array, array com as informações que serão gravadas na T8R
@param 			a1210, array, Array com informações usadas no posicionamento na T3P
@param 			cTable, array, Tabela T3P do S-1210 ou T2G do S-5002
@param 			lOk, array, Variavel lógica para validações
@param 			aIncons, array, Array que serão gravados os erros
/*/
//---------------------------------------------------------------------
Function TafGrvDIRF( aAnalitico as array, a1210 as array, cTable as character, lOk as logical, aIncons as array, lDeleteAll as logical )

	//Variáveis de controle de chave   
	Local cFil    	as character
	Local cId     	as character
	Local cVersao	as character
	Local cPerapur	as character
	Local cCPF		as character
	Local cKey		as character

	//Objetos e estruturas para gravação em lote
	Local oBulkT8R  as object  
	Local aT8R		as array
	Local aT8Rvalue	as array

	//Contadores
	Local nI        as numeric

	//Controle de área de trabalho
	Local aArea     as array

	//Parâmetros Default
	Default aAnalitico := {}
	Default a1210      := {}
	Default cTable     := ""
	Default lOk        := .F.
	Default aIncons    := {}
	Default lDeleteAll := .F.  

	//Inicialização das variáveis
	cFil      := ""
	cId       := ""
	cVersao   := ""
	cPerapur  := ""
	cCPF      := ""
	cKey	  := ""

	oBulkT8R  := Nil 
	aT8R      := {} 
	aT8Rvalue := {}
	
	nI        := 0

	//Guarda a área corrente
	aArea := FWGetArea( cTable )


	//Verifica se há dados para processar
	If Len( aAnalitico ) == 0
		TafConOut( "[TafGrvDIRF] AVISO: Array aAnalitico vazio" )
		Return .F.
	EndIf

	TafConOut( "[TafGrvDIRF] Iniciando gravação" )

	//=====================================================================
	// TRANSAÇÃO
	//=====================================================================
	Begin Transaction

		//Deleto se já existir registros com a mesma chave
		If lDeleteAll .And. cTable == "T3P"
			
			DbSelectArea( "T8R" )
			T8R->( DbSetOrder( 2 ) )
			
			// Itera pelos registros PRINCIPAIS (a1210)
			For nI := 1 To Len( a1210 )
				
				cFil     := PadR( cValToChar(a1210[nI][1]), TamSx3( "T3P_FILIAL" )[1] )
				cId      := PadR( cValToChar(a1210[nI][2]), TamSx3( "T3P_ID" )[1] )
				cCPF     := PadR( cValToChar(a1210[nI][4]), TamSx3( "T3P_CPF" )[1] )
				cPerapur := PadR( cValToChar(a1210[nI][5]), TamSx3( "T3P_PERAPU" )[1] )
				
				// Posiciona na T8R
				If T8R->( DbSeek( cFil + cId + cPerapur + cCPF ) )			
					// Deleta TODOS os registros desta chave
					TafDelDIRF( cFil, cId, cPerapur, cCPF )	
				EndIf
				
			Next nI
			
		EndIf
		
		// PREPARAÇÃO DA ESTRUTURA T8R (77 CAMPOS)
		aT8R :={{"T8R_FILIAL" },;
				{"T8R_ID    " },;
				{"T8R_VERSAO" },;
				{"T8R_PERAPU" },;
				{"T8R_CPF   " },;
				{"T8R_NOME  " },;
				{"T8R_EVENTO" },;
				{"T8R_CODREC" },;
				{"T8R_SEQUEN" },;
				{"T8R_VLRTRI" },;
				{"T8R_VRTR13" },;
				{"T8R_VLRPRE" },;
				{"T8R_VPRE13" },;
				{"T8R_VLIRRF" },;
				{"T8R_IRRF13" },;
				{"T8R_VLRISE" },;
				{"T8R_VLRI13" },;
				{"T8R_VLRDIA" },;
				{"T8R_VLRAJU" },;
				{"T8R_VLRRSC" },;
				{"T8R_VLRABN" },;
				{"T8R_VLRMLG" },;
				{"T8R_VMLG13" },;
				{"T8R_VLRAXM" },;
				{"T8R_VLBMED" },;
				{"T8R_BMED13" },;
				{"T8R_VLRMOR" },;
				{"T8R_VLRISO" },;
				{"T8R_TPREND" },;
				{"T8R_CPFDEP" },;
				{"T8R_VLRDED" },;
				{"T8R_TPRPAL" },;
				{"T8R_CPFDPA" },;
				{"T8R_VLRPAL" },;
				{"T8R_TPPREV" },;
				{"T8R_CNPJPC" },;
				{"T8R_VLDEPC" },;
				{"T8R_VLPC13" },;
				{"T8R_VLPCSP" },;
				{"T8R_PCVP13" },;
				{"T8R_TPPROC" },;
				{"T8R_NRPROC" },;
				{"T8R_CODSUP" },;
				{"T8R_INDAPU" },;
				{"T8R_VLRRTC" },;
				{"T8R_DEPJUD" },;
				{"T8R_CANOCA" },;
				{"T8R_CANOAN" },;
				{"T8R_RENDSU" },;
				{"T8R_INDDED" },;
				{"T8R_DEDSUS" },;
				{"T8R_CNPJEC" },;
				{"T8R_VLCONT" },;
				{"T8R_CPFSUS" },;
				{"T8R_DEPSUS" },;
				{"T8R_CNPJOP" },;
				{"T8R_REGANS" },;
				{"T8R_VLRPLS" },;
				{"T8R_CPFDPS" },;
				{"T8R_VLRDPS" },;
				{"T8R_ORIREE" },;
				{"T8R_CNPJPS" },;
				{"T8R_ANSRRE" },;
				{"T8R_INSCRE" },;
				{"T8R_NRPSRE" },;
				{"T8R_VLREEM" },;
				{"T8R_VLRANT" },;
				{"T8R_CPFRED" },;
				{"T8R_DINSCR" },;
				{"T8R_DNRPSR" },;
				{"T8R_DVLRRE" },;
				{"T8R_DVLRAN" },;
				{"T8R_FORABA" },;
				{"T8R_ABAFOL" },;
				{"T8R_PERREF" },;
				{"T8R_ORIGEM" },;
				{"T8R_RELACO" }}		

			//Cria o objeto de bulk para a tabela T8R
			oBulkT8R := FwBulk():New(RetSQLName("T8R"))			
			oBulkT8R:SetFields(aT8R)

			//Percorre os registros analíticos
			For nI := 1 to Len( aAnalitico ) 

				aT8Rvalue := {}

				//Carga de estrutura definida da T8R
				aadd( aT8Rvalue /*"T8R_FILIAL"*/, aAnalitico[nI][1])
				aadd( aT8Rvalue /*"T8R_ID     */, aAnalitico[nI][2])
				aadd( aT8Rvalue /*"T8R_VERSAO"*/, aAnalitico[nI][3])
				aadd( aT8Rvalue /*"T8R_PERAPU */, aAnalitico[nI][4])
				aadd( aT8Rvalue /*"T8R_CPF    */, aAnalitico[nI][5])
				aadd( aT8Rvalue /*"T8R_NOME  "*/, aAnalitico[nI][6])
				aadd( aT8Rvalue /*"T8R_EVENTO"*/, aAnalitico[nI][7])
				aadd( aT8Rvalue /*"T8R_CODREC"*/, aAnalitico[nI][8])
				aadd( aT8Rvalue /*"T8R_SEQUEN"*/, aAnalitico[nI][9])
				aadd( aT8Rvalue /*"T8R_VLRTRI"*/, aAnalitico[nI][10])
				aadd( aT8Rvalue /*"T8R_VRTR13"*/, aAnalitico[nI][11])
				aadd( aT8Rvalue /*"T8R_VLRPRE"*/, aAnalitico[nI][12])
				aadd( aT8Rvalue /*"T8R_VPRE13"*/, aAnalitico[nI][13])
				aadd( aT8Rvalue /*"T8R_VLIRRF"*/, aAnalitico[nI][14])
				aadd( aT8Rvalue /*"T8R_IRRF13"*/, aAnalitico[nI][15])
				aadd( aT8Rvalue /*"T8R_VLRISE"*/, aAnalitico[nI][16])
				aadd( aT8Rvalue /*"T8R_VLRI13"*/, aAnalitico[nI][17])
				aadd( aT8Rvalue /*"T8R_VLRDIA"*/, aAnalitico[nI][18])
				aadd( aT8Rvalue /*"T8R_VLRAJU"*/, aAnalitico[nI][19])
				aadd( aT8Rvalue /*"T8R_VLRRSC"*/, aAnalitico[nI][20])
				aadd( aT8Rvalue /*"T8R_VLRABN"*/, aAnalitico[nI][21])
				aadd( aT8Rvalue /*"T8R_VLRMLG"*/, aAnalitico[nI][22])
				aadd( aT8Rvalue /*"T8R_VMLG13"*/, aAnalitico[nI][23])
				aadd( aT8Rvalue /*"T8R_VLRAXM"*/, aAnalitico[nI][24])
				aadd( aT8Rvalue /*"T8R_VLBMED"*/, aAnalitico[nI][25])
				aadd( aT8Rvalue /*"T8R_BMED13"*/, aAnalitico[nI][26])
				aadd( aT8Rvalue /*"T8R_VLRMOR"*/, aAnalitico[nI][27])
				aadd( aT8Rvalue /*"T8R_VLRISO"*/, aAnalitico[nI][28])
				aadd( aT8Rvalue /*"T8R_TPREND"*/, aAnalitico[nI][29])
				aadd( aT8Rvalue /*"T8R_CPFDEP"*/, aAnalitico[nI][30])
				aadd( aT8Rvalue /*"T8R_VLRDED"*/, aAnalitico[nI][31])
				aadd( aT8Rvalue /*"T8R_TPRPAL"*/, aAnalitico[nI][32])
				aadd( aT8Rvalue /*"T8R_CPFDPA"*/, aAnalitico[nI][33])
				aadd( aT8Rvalue /*"T8R_VLRPAL"*/, aAnalitico[nI][34])
				aadd( aT8Rvalue /*"T8R_TPPREV"*/, aAnalitico[nI][35])
				aadd( aT8Rvalue /*"T8R_CNPJPC"*/, aAnalitico[nI][36])
				aadd( aT8Rvalue /*"T8R_VLDEPC"*/, aAnalitico[nI][37])
				aadd( aT8Rvalue /*"T8R_VLPC13"*/, aAnalitico[nI][38])
				aadd( aT8Rvalue /*"T8R_VLPCSP"*/, aAnalitico[nI][39])
				aadd( aT8Rvalue /*"T8R_PCVP13"*/, aAnalitico[nI][40])
				aadd( aT8Rvalue /*"T8R_TPPROC"*/, aAnalitico[nI][41])
				aadd( aT8Rvalue /*"T8R_NRPROC"*/, aAnalitico[nI][42])
				aadd( aT8Rvalue /*"T8R_CODSUP"*/, aAnalitico[nI][43])
				aadd( aT8Rvalue /*"T8R_INDAPU"*/, aAnalitico[nI][44])
				aadd( aT8Rvalue /*"T8R_VLRRTC"*/, aAnalitico[nI][45])
				aadd( aT8Rvalue /*"T8R_DEPJUD"*/, aAnalitico[nI][46])
				aadd( aT8Rvalue /*"T8R_CANOCA"*/, aAnalitico[nI][47])
				aadd( aT8Rvalue /*"T8R_CANOAN"*/, aAnalitico[nI][48])
				aadd( aT8Rvalue /*"T8R_RENDSU"*/, aAnalitico[nI][49])
				aadd( aT8Rvalue /*"T8R_INDDED"*/, aAnalitico[nI][50])
				aadd( aT8Rvalue /*"T8R_DEDSUS"*/, aAnalitico[nI][51])
				aadd( aT8Rvalue /*"T8R_CNPJEC"*/, aAnalitico[nI][52])
				aadd( aT8Rvalue /*"T8R_VLCONT"*/, aAnalitico[nI][53])
				aadd( aT8Rvalue /*"T8R_CPFSUS"*/, aAnalitico[nI][54])
				aadd( aT8Rvalue /*"T8R_DEPSUS"*/, aAnalitico[nI][55])
				aadd( aT8Rvalue /*"T8R_CNPJOP"*/, aAnalitico[nI][56])
				aadd( aT8Rvalue /*"T8R_REGANS"*/, aAnalitico[nI][57])
				aadd( aT8Rvalue /*"T8R_VLRPLS"*/, aAnalitico[nI][58])
				aadd( aT8Rvalue /*"T8R_CPFDPS"*/, aAnalitico[nI][59])
				aadd( aT8Rvalue /*"T8R_VLRDPS"*/, aAnalitico[nI][60])
				aadd( aT8Rvalue /*"T8R_ORIREE"*/, aAnalitico[nI][61])
				aadd( aT8Rvalue /*"T8R_CNPJPS"*/, aAnalitico[nI][62])
				aadd( aT8Rvalue /*"T8R_ANSRRE"*/, aAnalitico[nI][63])
				aadd( aT8Rvalue /*"T8R_INSCRE"*/, aAnalitico[nI][64])
				aadd( aT8Rvalue /*"T8R_NRPSRE"*/, aAnalitico[nI][65])
				aadd( aT8Rvalue /*"T8R_VLREEM"*/, aAnalitico[nI][66])
				aadd( aT8Rvalue /*"T8R_VLRANT"*/, aAnalitico[nI][67])
				aadd( aT8Rvalue /*"T8R_CPFRED"*/, aAnalitico[nI][68])
				aadd( aT8Rvalue /*"T8R_DINSCR"*/, aAnalitico[nI][69])
				aadd( aT8Rvalue /*"T8R_DNRPSR"*/, aAnalitico[nI][70])
				aadd( aT8Rvalue /*"T8R_DVLRRE"*/, aAnalitico[nI][71])
				aadd( aT8Rvalue /*"T8R_DVLRAN"*/, aAnalitico[nI][72])
				aadd( aT8Rvalue /*"T8R_FORABA"*/, aAnalitico[nI][73])
				aadd( aT8Rvalue /*"T8R_ABAFOL"*/, aAnalitico[nI][74])
				aadd( aT8Rvalue /*"T8R_PERREF"*/, aAnalitico[nI][75])
				aadd( aT8Rvalue /*"T8R_ORIGEM"*/, aAnalitico[nI][76])
				aadd( aT8Rvalue /*"T8R_RELACO"*/, aAnalitico[nI][77])

				//Adiciona o registro ao buffer de bulk
				oBulkT8R:AddData(aT8Rvalue)

				//Captura erro do bulk, se houver
				Iif(!Empty(oBulkT8R:GetError()), Aadd(aIncons, oBulkT8R:GetError()), aIncons)

				//Interrompe processamento se houver inconsistência
				If !Empty(aIncons)
					// Limpa objeto
					oBulkT8R:Destroy()
					oBulkT8R := nil
					Exit 
				EndIf

			Next nI

			//Gravação dos dados na tabela T8R
			If Empty(aIncons)
				// Grava os dados
				oBulkT8R:Flush()		
				Iif(Empty(oBulkT8R:GetError()), lOk := .T., Aadd(aIncons, oBulkT8R:GetError()) )			
				oBulkT8R:Close()
				// Limpa objeto
				oBulkT8R:Destroy()
				oBulkT8R := nil
			EndIf

			//Se dados gravados com sucesso
			If lOk

				TafConOut( "[TafGrvDIRF] Atualizando flag CHKDIR..." )
				DBSelectArea(cTable)
				( cTable )->( DbSetOrder( 1 ) )

				For nI := 1 to Len( a1210 ) 

					cFil    	:= a1210[nI][1]
					cId     	:= a1210[nI][2]
					cVersao		:= a1210[nI][3]

					cKey := PadR( cValToChar(cFil)	 , TamSx3( cTable + "_FILIAL" )[1] )+; 
					PadR( cValToChar(cId)	 , TamSx3( cTable + "_ID" )[1] )+; 
					PadR( cValToChar(cVersao), TamSx3( cTable + "_VERSAO" )[1] )

					//Altera o campo de controle da DIRF na tabela da folha
					If (cTable)->(DbSeek(cKey))
						If RecLock( cTable, .F. )
							(cTable)->&( cTable + "_CHKDIR" ) := .T. //Registro coletado com sucesso
							(cTable)->(MsUnlock())
						EndIf
					EndIf

				Next nI

			EndIf
		
	End Transaction

	TafConOut( "[TafGrvDIRF] =========================================" )
	TafConOut( "[TafGrvDIRF] Processamento concluído" )
	TafConOut( "[TafGrvDIRF] =========================================" )


	//Restaura área
	FwRestArea( aArea )

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFInitDIRF
@type        function
@description Chamada do Job da coleta da DIRF
@author      Alexandre de Lima Santos / Denis R. de Oliveira
@since       11/11/2025
@version     1.0
/*/
//-------------------------------------------------------------------
Function TAFInitDIRF()

    Local cEnv		as character
	Local cEmp		as character
    Local cFil  	as character 

	cEnv		:= GetEnvServer()
	cEmp		:= FWGrpCompany()
	cFil		:= FWCodFil()

	//Exibe mensagem de execução
	TAFConOut("Coleta do Relatório da DIRF")

	//Inicia a coleta para o relatório da DIRF
	StartJob("TAFColDirf", cEnv, .F., cEmp, cFil ) //Parâmetros enviados (Empresa+Filial)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TafDelDIRF
@type			function
@description	Deleta informações da tabela intermediária da DIRF.
@author Denis R de Oliveira
@since 11/11/2025
@param cfil   	 - Filial do registro
@param cId    	 - Id do registro
@param cPerApur	 - Periodo de apuracao
@param cCPF 	 - CPF do trabalhador
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TafDelDIRF( cFil as Character, cId as Character, cPerapur as Character, cCPF as Character )

	Local cDel1    as character
	Local cDel2    as character

	Default cFil      := ""
	Default cId       := ""
	Default cPerapur  := ""
	Default cCPF	  := ""	 

	cDel1 := ""
	cDel2 := ""

	//DELETE dos eventos principais (S-1200|S-1210|S-2299|S-2399)
	cDel1 := " DELETE FROM " + RetSqlName("T8R") + " "
	cDel1 += " WHERE T8R_FILIAL = '"   + cFil      + "' "
	cDel1 += "   AND T8R_ID = '"       + cId       + "' "
	cDel1 += "   AND T8R_PERAPU = '"   + cPerapur  + "' "
	cDel1 += "   AND T8R_CPF = '"      + cCPF      + "' "

	//DELETE específico do evento S-5002
	cDel2 := " DELETE FROM " + RetSqlName("T8R") + " "
	cDel2 += " WHERE T8R_FILIAL = '"   + cFil      + "' "
	cDel2 += "   AND T8R_PERAPU = '"   + cPerapur  + "' "
	cDel2 += "   AND T8R_CPF = '"      + cCPF      + "' "
	cDel2 += "   AND T8R_EVENTO = 'S-5002' "

	TCSQLExec( cDel1 )
	TCSQLExec( cDel2 )

	Tafconout("OK | TafDelDIRF | Registros removidos da T8R |")

Return ( Nil )



