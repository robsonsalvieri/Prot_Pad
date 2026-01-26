#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1156.CH"

Static nSaveSx8		:= 0				// Variavel para Controle de semaforo (Numeracao de Sequencia da Carga - campo "MBU_CODIGO")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156                          ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Abre o assistênte de geração de carga.                                 º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ Nenhum.                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nil                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA1156()
	Local oLJInitialLoadMakerWizard		:= Nil
	Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New()
	Local oLJCMessageManager				:= GetLJCMessageManager()//Controle Msgs
	Local aTableGroups					:= {}
	Local lDefaultDataCreated			:= .F.
	
	LjGrvLog( "Carga","ID_INICIO")

	//Trata msg ja no inico por causa da instancia do obj LJCFileServerConfiguration
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show(	STR0015 +	CHR(13)+CHR(10)	+; // "Configurações do servidor de carga não encontradas."
									STR0016 +	CHR(13)+CHR(10)	+; // "Caso esteja em um server diferente ou com balanceamento de cargas,"
									STR0017 +	CHR(13)+CHR(10)	+; // "Informe no servidor atual ou Slaves a configuração do servidor de cargas. Exemplo:"
									"[LJFileServer]" 			+	CHR(13)+CHR(10)	+;
									"Location=127.0.0.1"  	+	CHR(13)+CHR(10)	+;
									"Path=\ljfileserver\" 	+	CHR(13)+CHR(10)	+;
									"Port=8084"  				+	CHR(13)+CHR(10)	)
		oLJCMessageManager:Clear()
	EndIf

	DbSelectArea( "MBU" )
 	If Empty(MBU->(IndexKey(2)))
		Aviso(STR0008, STR0013 + CHR(13)+CHR(10) +; //#STR0008->"Atenção" ##STR0013->"O ambiente não está preparado para a utilização desta rotina."
						 STR0014, {"OK"})  //#STR0014->"Favor aplicar o update 'U_UPDLO105' ou entre em contato com o suporte."

	ElseIf FindFunction("__FWSeriNotCompactReady")
		aTableGroups := LOJA1156RDB()	
		
		If Len( aTableGroups ) == 0
			aTableGroups := LOJA1156CDB()
			lDefaultDataCreated	:= .T.
		EndIf
		
		oLJInitialLoadMakerWizard := LJCInitialLoadMakerWizard():New( aTableGroups )
		oLJInitialLoadMakerWizard:cPathOfRepository := oLJILFileServerConfiguration:GetPath()
		oLJInitialLoadMakerWizard:lHasChange := lDefaultDataCreated
		oLJInitialLoadMakerWizard:Show()	
		
	Else
		Aviso( STR0008, STR0001, {"OK"} ) // "Atenção!" "É necessário atualizar o fonte FWSERIALIZE.PRW"
	EndIf
	
	LjGrvLog( "Carga","ID_FIM")
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156CDB                       ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Administra Grupo de Tabelas Padroes.                                   º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ Nenhum.                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nil                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA1156CDB()
	Local oTransferTables	:= Nil
	Local aTableGroups		:= {}
	Local oTable1			:= Nil
	Local oTable2			:= Nil	
	Local oTable3			:= Nil	
	Local oTable4			:= Nil	
	Local oTable5			:= Nil	
	Local oTable6			:= Nil	
	Local oTable7			:= Nil	
	Local oTable8			:= Nil	
	Local oTable9			:= Nil	
	Local oTable10			:= Nil	
	Local oTable11			:= Nil	
	Local oTable12			:= Nil
	Local oTable13			:= Nil
	Local oCfgTab01			:= Nil
	Local oCfgTab02			:= Nil
	Local oCfgTab03			:= Nil
	Local oCfgTab04			:= Nil
	Local oCfgTab05			:= Nil
	Local oCfgTab06			:= Nil
	Local oCfgTab07			:= Nil
	Local oCfgTab08			:= Nil
	Local oCfgTab09			:= Nil
	Local oCfgTab10			:= Nil
	Local oCfgTab11			:= Nil
	Local oCfgTab12			:= Nil
	Local oCfgTab13			:= Nil
	Local oCfgTab14			:= Nil
	Local oCfgTab15			:= Nil
	Local oCfgTab16			:= Nil
	Local oCfgTab17			:= Nil
	Local oCfgTab18			:= Nil
	Local oCfgTab19			:= Nil
	Local oCfgTab20			:= Nil
	Local oCfgTab21			:= Nil
	Local oCfgTab22			:= Nil
	Local oCfgTab23			:= Nil
	Local oCfgTab24			:= Nil
	Local oCfgTab25			:= Nil
	Local oCfgTab26			:= Nil
	Local oCfgTab27			:= Nil
	Local oCfgTab28			:= Nil
	Local oCfgTab29			:= Nil
	Local oCfgTab30			:= Nil
	Local oCfgTab31			:= Nil
	Local oCfgTab32			:= Nil
	Local oCfgTab33			:= Nil
	Local oCfgTab34			:= Nil
	Local oCfgTab35			:= Nil	
	Local oCfgTab36			:= Nil
	Local oPTable1			:= Nil
	Local oSTable1			:= Nil
	Local lCfgTrib := If(FindFunction("LjCfgTrib"), LjCfgTrib(), .F.) //Verifica se Configurador de Tributos esta habilitado
	
	If MsgYesNo( STR0009 )
		oTransferTables := LJCInitialLoadTransferTables():New()

		oTable13 := LJCInitialLoadCompleteTable():New( "AI0", { xFilial( "AI0" ) } )			
		oTable1 := LJCInitialLoadCompleteTable():New( "SA1", { xFilial( "SA1" ) } )
		oTable2 := LJCInitialLoadCompleteTable():New( "SB0", { xFilial( "SB0" ) } )		
		oTable3 := LJCInitialLoadCompleteTable():New( "SB1", { xFilial( "SB1" ) } )		
		oTable4 := LJCInitialLoadCompleteTable():New( "SLK", { xFilial( "SLK" ) } )		
		oTable5 := LJCInitialLoadCompleteTable():New( "SAE", { xFilial( "SAE" ) } )		
		oTable6 := LJCInitialLoadCompleteTable():New( "SE4", { xFilial( "SE4" ) } )		
		oTable7 := LJCInitialLoadCompleteTable():New( "SF4", { xFilial( "SF4" ) } )		
		oTable8 := LJCInitialLoadCompleteTable():New( "SA6", { xFilial( "SA6" ) } )		
		oTable9 := LJCInitialLoadCompleteTable():New( "SLF", { xFilial( "SLF" ) } )		
		oTable10 := LJCInitialLoadCompleteTable():New( "SA6", { xFilial( "SA6" ) } )
		oTable11 := LJCInitialLoadCompleteTable():New( "SLF", { xFilial( "SLF" ) } )		
		oTable12 := LJCInitialLoadCompleteTable():New( "SA3", { xFilial( "SA3" ) } )
						
		oPTable1 := LJCInitialLoadPartialTable():New( "SX5" )
		oPTable1:AddRecord( 1, "23" )	
		
		oSTable1 := LJCInitialLoadSpecialTable():New( "SBI", { { xFilial( "SBI" ) }, "" } )

		oTransferTables:AddTable( oTable13 )		
		oTransferTables:AddTable( oTable1 )
		oTransferTables:AddTable( oTable2 )		
		oTransferTables:AddTable( oTable3 )
		oTransferTables:AddTable( oTable4 )		
		oTransferTables:AddTable( oTable5 )		
		oTransferTables:AddTable( oTable6 )		
		oTransferTables:AddTable( oTable7 )		
		oTransferTables:AddTable( oTable8 )		
		oTransferTables:AddTable( oTable9 )		
		oTransferTables:AddTable( oTable10 )		
		oTransferTables:AddTable( oTable11 )
		oTransferTables:AddTable( oTable12 )
									
		oTransferTables:AddTable( oPTable1 )

		oTransferTables:AddTable( oSTable1 )

		//Tabelas Configurador de Tributos
		If lCfgTrib
			oCfgTab01 := LJCInitialLoadCompleteTable():New( "CIN", { xFilial( "CIN" ) } )
			oCfgTab02 := LJCInitialLoadCompleteTable():New( "CIO", { xFilial( "CIO" ) } )
			oCfgTab03 := LJCInitialLoadCompleteTable():New( "CIQ", { xFilial( "CIQ" ) } )
			oCfgTab04 := LJCInitialLoadCompleteTable():New( "CIR", { xFilial( "CIR" ) } )
			oCfgTab05 := LJCInitialLoadCompleteTable():New( "CIS", { xFilial( "CIS" ) } )
			oCfgTab06 := LJCInitialLoadCompleteTable():New( "CIT", { xFilial( "CIT" ) } )
			oCfgTab07 := LJCInitialLoadCompleteTable():New( "CIU", { xFilial( "CIU" ) } )
			oCfgTab08 := LJCInitialLoadCompleteTable():New( "CIV", { xFilial( "CIV" ) } )
			oCfgTab09 := LJCInitialLoadCompleteTable():New( "CIX", { xFilial( "CIX" ) } )
			oCfgTab10 := LJCInitialLoadCompleteTable():New( "CIY", { xFilial( "CIY" ) } )
			oCfgTab11 := LJCInitialLoadCompleteTable():New( "CJ0", { xFilial( "CJ0" ) } )
			oCfgTab12 := LJCInitialLoadCompleteTable():New( "CJ1", { xFilial( "CJ1" ) } )
			oCfgTab13 := LJCInitialLoadCompleteTable():New( "CJ2", { xFilial( "CJ2" ) } )
			oCfgTab14 := LJCInitialLoadCompleteTable():New( "CJ4", { xFilial( "CJ4" ) } )
			oCfgTab15 := LJCInitialLoadCompleteTable():New( "CJ5", { xFilial( "CJ5" ) } )
			oCfgTab16 := LJCInitialLoadCompleteTable():New( "CJ6", { xFilial( "CJ6" ) } )
			oCfgTab17 := LJCInitialLoadCompleteTable():New( "CJ7", { xFilial( "CJ7" ) } )
			oCfgTab18 := LJCInitialLoadCompleteTable():New( "CJ8", { xFilial( "CJ8" ) } )
			oCfgTab19 := LJCInitialLoadCompleteTable():New( "CJ9", { xFilial( "CJ9" ) } )
			oCfgTab20 := LJCInitialLoadCompleteTable():New( "CJA", { xFilial( "CJA" ) } )
			oCfgTab21 := LJCInitialLoadCompleteTable():New( "CJL", { xFilial( "CJL" ) } )
			oCfgTab22 := LJCInitialLoadCompleteTable():New( "F20", { xFilial( "F20" ) } )
			oCfgTab23 := LJCInitialLoadCompleteTable():New( "F21", { xFilial( "F21" ) } )
			oCfgTab24 := LJCInitialLoadCompleteTable():New( "F22", { xFilial( "F22" ) } )
			oCfgTab25 := LJCInitialLoadCompleteTable():New( "F23", { xFilial( "F23" ) } )
			oCfgTab26 := LJCInitialLoadCompleteTable():New( "F24", { xFilial( "F24" ) } )
			oCfgTab27 := LJCInitialLoadCompleteTable():New( "F25", { xFilial( "F25" ) } )
			oCfgTab28 := LJCInitialLoadCompleteTable():New( "F26", { xFilial( "F26" ) } )
			oCfgTab29 := LJCInitialLoadCompleteTable():New( "F27", { xFilial( "F27" ) } )
			oCfgTab30 := LJCInitialLoadCompleteTable():New( "F28", { xFilial( "F28" ) } )
			oCfgTab31 := LJCInitialLoadCompleteTable():New( "F29", { xFilial( "F29" ) } )
			oCfgTab32 := LJCInitialLoadCompleteTable():New( "F2A", { xFilial( "F2A" ) } )
			oCfgTab33 := LJCInitialLoadCompleteTable():New( "F2B", { xFilial( "F2B" ) } )
			oCfgTab34 := LJCInitialLoadCompleteTable():New( "F2C", { xFilial( "F2C" ) } )
			oCfgTab35 := LJCInitialLoadCompleteTable():New( "F2E", { xFilial( "F2E" ) } )
			oCfgTab36 := LJCInitialLoadCompleteTable():New( "F2F", { xFilial( "F2F" ) } )

			oTransferTables:AddTable( oCfgTab01 )
			oTransferTables:AddTable( oCfgTab02 )
			oTransferTables:AddTable( oCfgTab03 )
			oTransferTables:AddTable( oCfgTab04 )
			oTransferTables:AddTable( oCfgTab05 )
			oTransferTables:AddTable( oCfgTab06 )
			oTransferTables:AddTable( oCfgTab07 )
			oTransferTables:AddTable( oCfgTab08 )
			oTransferTables:AddTable( oCfgTab09 )
			oTransferTables:AddTable( oCfgTab10 )
			oTransferTables:AddTable( oCfgTab11 )
			oTransferTables:AddTable( oCfgTab12 )
			oTransferTables:AddTable( oCfgTab13 )
			oTransferTables:AddTable( oCfgTab14 )
			oTransferTables:AddTable( oCfgTab15 )
			oTransferTables:AddTable( oCfgTab16 )
			oTransferTables:AddTable( oCfgTab17 )
			oTransferTables:AddTable( oCfgTab18 )
			oTransferTables:AddTable( oCfgTab19 )
			oTransferTables:AddTable( oCfgTab20 )
			oTransferTables:AddTable( oCfgTab21 )
			oTransferTables:AddTable( oCfgTab22 )
			oTransferTables:AddTable( oCfgTab23 )
			oTransferTables:AddTable( oCfgTab24 )
			oTransferTables:AddTable( oCfgTab25 )
			oTransferTables:AddTable( oCfgTab26 )
			oTransferTables:AddTable( oCfgTab27 )
			oTransferTables:AddTable( oCfgTab28 )
			oTransferTables:AddTable( oCfgTab29 )
			oTransferTables:AddTable( oCfgTab30 )
			oTransferTables:AddTable( oCfgTab31 )
			oTransferTables:AddTable( oCfgTab32 )
			oTransferTables:AddTable( oCfgTab33 )
			oTransferTables:AddTable( oCfgTab34 )
			oTransferTables:AddTable( oCfgTab35 )
			oTransferTables:AddTable( oCfgTab36 )
		EndIf

		aTableGroups := { { "1", STR0010, STR0011, oTransferTables, "1" } }		
	EndIf
Return aTableGroups

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156RDB                       ³ Autor: Vendas CRM ³ Data: 16/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Le do banco de dados as informações dos grupos de tabelas disponíveis. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ Nenhum.                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ aTableGroups: Array com os grupos de tabelas disponíveis.              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA1156RDB()

Local aTableGroups	:= {}
Local oTransfTbl	:= LJCInitialLoadTransferTables():New()
Local lNewLoad		:= ExistFunc("Lj1149NwLd")

DbSelectArea( "MBU" )
DbSetOrder(2)
DbGoTop()	

While MBU->( !EOF() ) .AND. MBU->MBU_TIPO <> '2'  //soh mostra templates (nao mostra o que for carga gerada)
	aAdd( aTableGroups, Array( 5 ) )
	aTableGroups[Len(aTableGroups)][1] := MBU->MBU_CODIGO
	aTableGroups[Len(aTableGroups)][2] := MBU->MBU_NOME
	aTableGroups[Len(aTableGroups)][3] := MBU->MBU_DESCRI
	If lNewLoad
		aTableGroups[Len(aTableGroups)][4] := oTransfTbl
	Else
		aTableGroups[Len(aTableGroups)][4] := LOJA1156RTG( MBU->MBU_CODIGO )
	EndIf	
	aTableGroups[Len(aTableGroups)][5] := MBU->MBU_INTINC
	
	MBU->( DbSkip() )
End

Return aTableGroups

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156RTG                       ³ Autor: Vendas CRM ³ Data: 16/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Le um grupo de tabela e retorna seu LJCInitialLoadTransferTables.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ Nenhum.                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ oTransferTables: Objeto do tipo LJCInitialLoadTransferTables.          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA1156RTG( cTableGroup )
	Local oTransferTables	:= LJCInitialLoadTransferTables():New()
	Local oTempTable		:= Nil
	Local aBranches			:= {}
	Local aRecords			:= {}
	Local aParams			:= {}	
	
	DbSelectArea( "MBV" )
	DbSetOrder( 1 )
	If MBV->( DbSeek( xFilial( "MBV" ) + cTableGroup ) )
		While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + cTableGroup .And.;
				MBV->( !EOF() )
			oTempTable := Nil
			//tipo -> completa
			If AllTrim( MBV->MBV_TIPO ) == "1"
				oTempTable := LJCInitialLoadCompleteTable():New( MBV->MBV_TABELA )
				aBranches := {}
				DbSelectArea( "MBX" )
				DbSetOrder( 1 )
				If MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
					While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
							MBX->( !EOF() )
						aAdd( aBranches, MBX->MBX_FIL )
						MBX->( DbSkip() )
					End
				EndIf
				oTempTable:aBranches := aBranches
				
				oTempTable:cFilter := MBV->MBV_FILTRO 
			
				oTempTable:cQtyRecords := MBV->MBV_QTDREG
			//tipo -> parcial	
			ElseIf AllTrim( MBV->MBV_TIPO ) == "2"
				oTempTable := LJCInitialLoadPartialTable():New( MBV->MBV_TABELA )
				aRecords := {}
				DbSelectArea( "MBW" )
				DbSetOrder( 1 )
				If MBW->( DbSeek( xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
					While	MBW->MBW_FILIAL + MBW->MBW_CODGRP + MBW->MBW_TABELA == xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
							MBW->( !EOF() )
						aAdd( aRecords, { MBW->MBW_INDICE, MBW->MBW_SEEK  } )
						MBW->( DbSkip() )
					End
				EndIf
				oTempTable:aRecords := aRecords
				
				oTempTable:cFilter := MBV->MBV_FILTRO
				
				oTempTable:cQtyRecords := MBV->MBV_QTDREG
			//tipo -> especial
			ElseIf AllTrim( MBV->MBV_TIPO ) == "3"
				oTempTable := LJCInitialLoadSpecialTable():New( MBV->MBV_TABELA )
				If MBV->MBV_TABELA == "SBI"
					aParams := Array( 2 )
					aBranches := {}
					DbSelectArea( "MBX" )
					DbSetOrder( 1 )
					If MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
						While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
								MBX->( !EOF() )
							aAdd( aBranches, MBX->MBX_FIL )
							MBX->( DbSkip() )
						End
					EndIf
					aParams[1] := aBranches
					
					aParams[2] := MBV->MBV_FILTRO
					
					oTempTable:aParams := aParams
					oTempTable:cQtyRecords := MBV->MBV_QTDREG
				EndIf
			EndIf
			aAdd( oTransferTables:aoTables, oTempTable )
			MBV->( DbSkip() )
		End
	EndIf
Return oTransferTables

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156WDB                       ³ Autor: Vendas CRM ³ Data: 16/10/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Grava os grupos de tabelas disponíveis no banco de dados.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ aTableGroups: Array com os grupos de tabelas disponíveis.              º±±
±±º             ³ lLoad: determina se eh uma carga (.T.) ou um template (.F.)            º±±
±±º             ³ cCodInitialLoad:Codigo da carga (quando lLoad = .T.), por referencia   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nenhum.                                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LOJA1156WDB( aTableGroups, lLoad, cCodInitialLoad )
	Local nCount 		:= 0
	Local nCount2		:= 0
	Local nCount3		:= 0
	Local aProcGroups	:= {}
	Local aProcTables	:= {}
	Local cOrderLoad 	:= MBUOrderIncremental() //verifica antes a ordem da proxima carga, porque se precisar criar o xml vai ter q percorrer as tabelas MB's antes de incluir outro registro
	Local cCodMBU		:= ""
	
	Default lLoad := .F. //determina se eh uma carga (.T.) ou um template (.F.)
	
	LjGrvLog( "Carga","Geração carga Inicio ")
	
	For nCount := 1 To Len( aTableGroups )			
		// Procura informações do grupo de tabela, se não encontrar, cria ela.
		DbSelectArea( "MBU" )
		DbSetOrder(1)
		DbGoTop()			
		If (lLoad) .OR. Empty(aTableGroups[nCount][1]) .OR. MBU->( !DbSeek( xFilial( "MBU" ) + aTableGroups[nCount][1] ) )
			LJSetSvSx8(GetSx8Len()) // Controle de semaforo

			cCodMBU := GetSXENum( "MBU", "MBU_CODIGO" )
			LjGrvLog( "Carga","MBU_CODIGO ",cCodMBU )
			If MBU->(!DbSeek(xFilial("MBU")+cCodMBU))
				RecLock( "MBU", .T. )
				Replace MBU->MBU_FILIAL	With xFilial( "MBU" )
				Replace MBU->MBU_CODIGO	With cCodMBU
				MBU->(MsUnLock())
			EndIf						
			aAdd( aProcGroups, MBU->MBU_CODIGO )
			
			//Popula tabela MH1 para execucao da carga automatica via JOB ou Scheduller
			If AliasInDic("MH1") .AND. Alltrim(aTableGroups[nCount][5]) == "2"	 //Se for somente carga incremental e gera automática e for template
				DbSelectArea("MH1")
				MH1->(dbSetOrder(1))		
				If !MH1->(dbSeek(xFilial("MH1")+(IIF(lLoad , aTableGroups[nCount][1], cCodMBU ))))  
					LjGrvLog( "Carga","Cria registro para geração automática ")
					RecLock( "MH1", .T. )
					MH1->MH1_FILIAL	:= xFilial("MH1")
					MH1->MH1_COD		:= (IIF(lLoad , aTableGroups[nCount][1], cCodMBU ))
					MH1->MH1_TIME		:= 1
					MH1->MH1_STATUS	:= "A"
					MH1->MH1_HORAI	:= "00:00"
					MH1->MH1_HORAF	:= "23:59"
					MH1->(MsUnLock())
				EndIf		
			EndIf
			
			If !lLoad //se for um registro de template joga o codigo do registro na columa 1 do array dos grupos
				ConfirmSx8() //Confirma a numeracao gerada para esta carga
				aTableGroups[nCount][1] := MBU->MBU_CODIGO
			Else //se for um registro de carga, devolve pelo parametro por referencia, o codigo da carga
				cCodInitialLoad :=  MBU->MBU_CODIGO
			EndIf
			
		Else
			aAdd( aProcGroups, aTableGroups[nCount][1] )
		EndIf
	
		If RecLock( "MBU", .F. )
			Replace MBU->MBU_NOME 		With aTableGroups[nCount][2]
			Replace MBU->MBU_DESCRI 		With aTableGroups[nCount][3]
			Replace MBU->MBU_TIPO 		With (IIF(lLoad , "2", "1"))
			Replace MBU->MBU_INTINC		With IIF( Empty(aTableGroups[nCount][5]) , "1" , aTableGroups[nCount][5]) //se tiver em branco (cargas antigas, legado) considera como carga inteira. Dessa forma as cargas antes desta versao serao convertidas para o tipo "carga inteira"
			
			If lLoad //grava dados exclusivos do tipo = carga (MBU_TIPO = 2)
				LjGrvLog( "Carga","Grava resgistros exclusivos ")
				Replace MBU->MBU_DATA	With dDataBase
				Replace MBU->MBU_HORA	With Time()
				Replace MBU->MBU_CODTPL	With aTableGroups[nCount][1] //codigo do template usado na carga (auto-associacao na MBU)
				//carga incremental controla a ordem
				If aTableGroups[nCount][5] == '2'
					Replace MBU->MBU_ORDEM	With cOrderLoad
				EndIf
			EndIf
			
			MBU->(MsUnLock())
		Else
			LjGrvLog( "Carga","Não conseguiu efetuar RecLock na tabela MBU ")
		EndIf	
		
		aProcTables := {}	
		For nCount2 := 1 To Len( aTableGroups[nCount][4]:aoTables )		
			// Adiciona a tabela na lista de tabelas processadas
			aAdd( aProcTables, aTableGroups[nCount][4]:aoTables[nCount2]:cTable )
		
			// Procura informações da tabela, se não encontrar, cria ela.
			DbSelectArea( "MBV" )
			DbSetOrder( 1 )
			If MBV->( !DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO + aTableGroups[nCount][4]:aoTables[nCount2]:cTable ) )
				RecLock( "MBV", .T. )
				Replace MBV->MBV_FILIAL	With xFilial( "MBV" )
				Replace MBV->MBV_CODGRP	With MBU->MBU_CODIGO
				Replace MBV->MBV_TABELA	With aTableGroups[nCount][4]:aoTables[nCount2]:cTable 
				MBV->(MsUnLock())
			EndIf
	
			If Lower(GetClassName( aTableGroups[nCount][4]:aoTables[nCount2] )) == Lower("LJCInitialLoadCompleteTable")
				// Grava
				RecLock( "MBV", .F. )
				Replace MBV->MBV_TIPO	With "1"
				Replace MBV->MBV_FILTRO With aTableGroups[nCount][4]:aoTables[nCount2]:cFilter
				MBV->(MsUnLock())
	
				// Apaga as filiais no MBX
				DbSelectArea( "MBX" )
				DbSetOrder( 1 )
				MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )
				While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
						MBX->( !EOF() )
					RecLock( "MBX", .F. )
					MBX->( DbDelete() )
					MBX->( MsUnLock() )
					MBX->( DbSkip() )
				End

				For nCount3 := 1 To Len( aTableGroups[nCount][4]:aoTables[nCount2]:aBranches )
					RecLock( "MBX", .T. )
					Replace MBX->MBX_FILIAL	With xFilial( "MBX" )
					Replace MBX->MBX_CODGRP	With MBV->MBV_CODGRP
					Replace MBX->MBX_TABELA	With MBV->MBV_TABELA
					Replace MBX->MBX_FIL	With aTableGroups[nCount][4]:aoTables[nCount2]:aBranches[nCount3]
					MBX->( MsUnLock() )
				Next
			ElseIf Lower(GetClassName( aTableGroups[nCount][4]:aoTables[nCount2] )) == Lower("LJCInitialLoadPartialTable")
				RecLock( "MBV", .F. )
				Replace MBV->MBV_TIPO	With "2"
				Replace MBV->MBV_FILTRO With aTableGroups[nCount][4]:aoTables[nCount2]:cFilter
				MBV->(MsUnLock())

				// Apaga os registros no MBW
				DbSelectArea( "MBW" )
				DbSetOrder( 1 )
				If MBW->( DbSeek( xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )					
					While	MBW->MBW_FILIAL + MBW->MBW_CODGRP + MBW->MBW_TABELA == xFilial( "MBW" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
							MBW->( !EOF() )
						RecLock( "MBW", .F. )
						MBW->( DbDelete() )
						MBW->( MsUnLock() )						
						MBW->( DbSkip() )
					End
				EndIf	   
		
				For nCount3 := 1 To Len( aTableGroups[nCount][4]:aoTables[nCount2]:aRecords )
					RecLock( "MBW", .T. )
					Replace MBW->MBW_FILIAL	With xFilial( "MBW" )
					Replace MBW->MBW_CODGRP	With MBV->MBV_CODGRP
					Replace MBW->MBW_TABELA	With MBV->MBV_TABELA
					Replace MBW->MBW_INDICE	With aTableGroups[nCount][4]:aoTables[nCount2]:aRecords[nCount3][1]
					Replace MBW->MBW_SEEK	With aTableGroups[nCount][4]:aoTables[nCount2]:aRecords[nCount3][2]
					MBW->( MsUnLock() )
				Next				
			ElseIf Lower(GetClassName( aTableGroups[nCount][4]:aoTables[nCount2] )) == Lower("LJCInitialLoadSpecialTable")				
				RecLock( "MBV", .F. )
				Replace MBV->MBV_TIPO	With "3"
				Replace MBV->MBV_FILTRO With aTableGroups[nCount][4]:aoTables[nCount2]:aParams[2]
				MBV->(MsUnLock())
				
				// Apaga as filiais no MBX
				DbSelectArea( "MBX" )
				DbSetOrder( 1 )
				MBX->( DbSeek( xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA ) )
				While	MBX->MBX_FILIAL + MBX->MBX_CODGRP + MBX->MBX_TABELA == xFilial( "MBX" ) + MBV->MBV_CODGRP + MBV->MBV_TABELA .And.;
						MBX->( !EOF() )
					RecLock( "MBX", .F. )
					MBX->( DbDelete() )
					MBX->( MsUnLock() )
					MBX->( DbSkip() )
				End
		
				For nCount3 := 1 To Len( aTableGroups[nCount][4]:aoTables[nCount2]:aParams[1] )
					RecLock( "MBX", .T. )
					Replace MBX->MBX_FILIAL	With xFilial( "MBX" )
					Replace MBX->MBX_CODGRP	With MBV->MBV_CODGRP
					Replace MBX->MBX_TABELA	With MBV->MBV_TABELA
					Replace MBX->MBX_FIL	With aTableGroups[nCount][4]:aoTables[nCount2]:aParams[1][nCount3]
					MBX->( MsUnLock() )
				Next				
			EndIf
		Next

		// Apaga as tabelas desse grupo
		DbSelectArea( "MBV" )
		DbSetOrder( 1 )
		If MBV->( DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO ) )
			While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + MBU->MBU_CODIGO .And.;
					MBV->( !EOF() )
				If Len(aProcTables) > 0 .And. aScan( aProcTables, { |x| x == MBV->MBV_TABELA } ) == 0
					RecLock( "MBV", .F. )
					MBV->( DbDelete() )
					MBV->( MsUnLock() )
				EndIf
				MBV->( DbSkip() )				
			End
		EndIf
	Next
	
	//Se for do tipo template, apaga os grupos (que tenham sido removidos pelo usuario) e suas tabelas 
	If !lLoad 
		LjGrvLog( "Carga","Apaga Grupos removidos pelo usuario ")
		DbSelectArea( "MBU" )
		DbSetOrder(2)
		DbGoTop()	
		While MBU->( !EOF() ) .AND. MBU->MBU_TIPO <> "2" //somente templates (tipo 1 = template, 2 = carga - se for registro antigo, o campo tipo pode estar em branco)
	   		If aScan( aProcGroups, { |x| x == MBU->MBU_CODIGO } ) == 0
				RecLock( "MBU", .F. )
				MBU->( DbDelete() )
				MBU->( MsUnLock() )
				
				// Apaga as tabelas desse grupo
				DbSelectArea( "MBV" )//MBV_FILIAL+MBV_CODGRP+MBV_TABELA
				DbSetOrder( 1 )
				If MBV->( DbSeek( xFilial( "MBV" ) + MBU->MBU_CODIGO ) )
					While	MBV->MBV_FILIAL + MBV->MBV_CODGRP ==  xFilial( "MBV" ) + MBU->MBU_CODIGO .And.;
							MBV->( !EOF() )
						RecLock( "MBV", .F. )
						MBV->( DbDelete() )
						MBV->( MsUnLock() )
						MBV->( DbSkip() )				
					End
				EndIf

				DbSelectArea( "MBX" )//MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL
				DbSetOrder( 1 )
				If MBX->( DbSeek( xFilial( "MBX" ) + MBU->MBU_CODIGO ) )
					While	MBX->MBX_FILIAL + MBX->MBX_CODGRP ==  xFilial( "MBX" ) + MBU->MBU_CODIGO .And.;
							MBX->( !EOF() )
						RecLock( "MBX", .F. )
						MBX->( DbDelete() )
						MBX->( MsUnLock() )
						MBX->( DbSkip() )				
					End
				EndIf

			EndIf
			MBU->( DbSkip() )
		End		                   
	EndIf
	
	LjGrvLog( "Carga","Geração carga Inicio ")
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156Job                       ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Executa a geração de carga através de JOB.                             º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ cTableGroup: codigo da grupo de tabelas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nil                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                       	
Function LOJA1156Job( cTableGroup, cCodAgenda, cEmpCarga, cFilCarga )
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local oLJLoadUI						:= LJCInitialLoadMakerConsoleUI():New()
	Local oLJILFileServerConfiguration	:= LJCFileServerConfiguration():New()	
	Local oLJInitialLoad				:= Nil
	Local lRet							:= .F.
	Local cCodInitialLoad				:= ""  //codigo da carga inicial (carga em si, nao o template)
	Local cEntireInc					:= ""
	Local cName							:= ""
	Local cDesc							:= ""
	Local oTransferTables				:= Nil
	
	Default cCodAgenda 	:= ""
	Default cEmpCarga 	:= ""
	Default cFilCarga	:= ""

	If !Empty(cCodAgenda)
		//Inicia o ambiente
		RPCSetType(3)	  	
		RpcSetEnv(cEmpCarga, cFilCarga,,,"FRT")

		//Atualiza informações de data inicial/final e numero da thread
		DbSelectArea("MIO")
		MIO->(DbSetOrder(1)) //MIO_FILIAL+MIO_SEQ
		If MIO->(DbSeek(xFilial("MIO") + PadR(cCodAgenda, TamSx3("MIO_SEQ")[1])))
			RecLock( "MIO", .F. )
			MIO->MIO_HRINI 	:= FWTimeStamp(2)
			MIO->MIO_HRFIM 	:= ""
			MIO->MIO_THREAD := cValToChar(ThreadID())
			MIO->(MsUnlock())
		EndIf
		cTableGroup := PadR(cTableGroup, TamSx3("MBU_CODIGO")[1])
		LjGrvLog( "Carga", "Inicio da geração da carga - Grupo de tabelas: " + AllTrim(MIO->MIO_GRPCAR) + " - Thread: " + AllTrim(MIO->MIO_THREAD) + " - Data/Hora: " + MIO->MIO_HRINI )
		CoNout("Inicio da geracao da carga - Grupo de tabelas: " + AllTrim(MIO->MIO_GRPCAR) + " - Thread: " + AllTrim(MIO->MIO_THREAD) + " - Data/Hora: " + MIO->MIO_HRINI)
	Else
		LjGrvLog( "Carga","ID_INICIO")	
	EndIf
	
	//Trata msg ja no inico por causa da instancia do obj LJCFileServerConfiguration
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show(	STR0015 +	CHR(13)+CHR(10)	+; // "Configurações do servidor de carga não encontradas."
									STR0016 +	CHR(13)+CHR(10)	+; // "Caso esteja em um server diferente ou com balanceamento de cargas,"
									STR0017 +	CHR(13)+CHR(10)	+; // "Informe no servidor atual ou Slaves a configuração do servidor de cargas. Exemplo:"
									"[LJFileServer]" 			+	CHR(13)+CHR(10)	+;
									"Location=127.0.0.1"  	+	CHR(13)+CHR(10)	+;
									"Path=\ljfileserver\" 	+	CHR(13)+CHR(10)	+;
									"Port=8084"  				+	CHR(13)+CHR(10)	)
		oLJCMessageManager:Clear()
	EndIf
	
	If ValType(cTableGroup) <> "C" .OR. Empty( cTableGroup ) 
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LOJA1156Job", 1, STR0012 ) ) // "Não foi informado um codigo de grupo de tabelas."
	Else
		oTransferTables := LOJA1156RTG( cTableGroup )	
	EndIf
	
	If !oLJCMessageManager:HasError()
		
		cEntireInc	:= Posicione("MBU", 1, XFilial("MBU") + cTableGroup , "MBU_INTINC")
		cName		:= Posicione("MBU", 1, XFilial("MBU") + cTableGroup , "MBU_NOME")
		cDesc		:= Posicione("MBU", 1, XFilial("MBU") + cTableGroup , "MBU_DESCRI")
	  	aTableGroups := { { cTableGroup, cName, cDesc, oTransferTables, cEntireInc } }	
	       
	 	//Grava a carga que sera gerada e pega o codigo dela por referencia
		LOJA1156WDB( aTableGroups, .T., @cCodInitialLoad )
		
		oLJInitialLoad := LJCInitialLoadMaker():New( oLJILFileServerConfiguration:GetPath() + cCodInitialLoad )//concatena no path o codigo da carga 	
		oLJInitialLoad:SetTransferTables( oTransferTables )
		oLJInitialLoadMaker:SetExportType(cEntireInc)		
		oLJInitialLoadMaker:SetCodInitialLoad( cCodInitialLoad )
		oLJLoadUI := LJCInitialLoadMakerConsoleUI():New()
		oLJInitialLoad:AddObserver( oLJLoadUI )
		oLJInitialLoad:Execute()			
		If !oLJCMessageManager:HasError()
			
			LJ1156XMLResult()
			
			lRet := .T.
		EndIf			
	EndIf
		
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0003 ) // "Houve alguma mensagem durante a geração da carga."
		oLJCMessageManager:Clear()
	EndIf

	If !Empty(cCodAgenda)
		RecLock( "MIO", .F. )
		MIO->MIO_HRFIM 	:= FWTimeStamp(2)
		MIO->(MsUnlock())
		LjGrvLog( "Carga", "Fim da geração da carga - Grupo de tabelas: " + AllTrim(MIO->MIO_GRPCAR) + " - Thread: " + AllTrim(MIO->MIO_THREAD) + " - Data/Hora: " + MIO->MIO_HRFIM )
		CoNout("Fim da geracao da carga - Grupo de tabelas: " + AllTrim(MIO->MIO_GRPCAR) + " - Thread: " + AllTrim(MIO->MIO_THREAD) + " - Data/Hora: " + MIO->MIO_HRFIM)
	Else
		LjGrvLog( "Carga","ID_FIM")
	EndIf
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LOJA1156PJob                      ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Geração de carga por solicitação do painél de precificação.            º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ cTableGroup: Código do grupo de tabelas a ser utilizado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nil                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                       	
Function LOJA1156PJob( cTableGroup )
	Local oObject  := nil
	Local lPainel  := .F.

	lPainel := SuperGetMV("MV_LJGEPRE",.F.,.F.)
	
	If lPainel
		oObject := PainelPrecificacao():New()
		
		If oObject:Lj3GerarCarga()
			oObject:Lj3ExecCarga(LOJA1156Job( cTableGroup ))
		EndIf
	EndIf
	
Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ MBUOrderIncremental               ³ Autor: Vendas CRM ³ Data: 07/08/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Busca a ordem da proxima carga incremental                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ cOrder: proximo numero da ordem                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                       	
Function MBUOrderIncremental()
Local cOrder		:= ""

cOrder := LJILLastOrderLoad()
If Empty(cOrder) //se nao tiver a ordem gravada, forca a gravacao baseada na ultim carga do xml (gera novamente o xml pra garantir que esta atualizado)
	LJ1156XMLResult(.T.)
	cOrder := LJILLastOrderLoad()
EndIf

cOrder := cValToChar(Val(cOrder) + 1) //soma +1
cOrder := PADL(cOrder,10,'0') //preenche com 0 a esquerda

LjGrvLog( "Carga","Ordem da proxima carga incremental " + cOrder )

Return cOrder



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LJ1156CountLoads               ³ Autor: Vendas CRM ³ Data: 07/08/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ retorna o total de cargas incrementais                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno:     nTotalLoads: total de cargas incrementais                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                       	
Function LJ1156CountLoads()
Local cQuery		:= ""
Local nTotalLoads		:= 0


//verifica o total de cargas (considera somente registros do tipo carga (2). Nao considera os templates(1)
cQuery := " SELECT COUNT(*) AS TOTLOAD FROM " + RetSqlName('MBU') + " WHERE MBU_TIPO = '2' AND D_E_L_E_T_ = ' ' " 
cQuery := ChangeQuery(cQuery)					
dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),'TMP', .F., .T.)
nTotalLoads := TMP->TOTLOAD
TMP->(dbCloseArea()) 

LjGrvLog( "Carga","Total de cargas incrementais ", nTotalLoads )

Return nTotalLoads


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Função: ³ LJ1156XMLResult                   ³ Autor: Vendas CRM ³ Data: 06/07/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ cria o xml com o resultado serializado (lista das cargas)              º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Parametro: ³ lUpdateOrderLoad: forca a criacao do xml da ultima carga               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                 

Function LJ1156XMLResult(lUpdateOrderLoad)

Local oLJILConfiguration	:= LJCInitialLoadConfiguration():New()	
Local oResult				:= Nil		//objeto tipo LJCInitialLoadMakerResult -> array de LJCInitialLoadGroupConfig 
Local oTransferTable		:= Nil		
Local oTransferFiles		:= Nil
Local oFile				:= Nil
Local oGroup				:= Nil		//objeto tipo LJCInitialLoadGroupConfig com dados de uma carga especifica
Local nCountTable			:= 0
Local nCountBranche		:= 0
Local nI					:= 0
Local cLastOrder			:= ""

Default lUpdateOrderLoad := .F. //quando for true, forca a criacao do xml da ultima carga mesmo que a ordem seja inferior a ultima (isso ocorre quando restaura o msexp)

LjGrvLog( "Carga","Grava XML com resultado da geração da carga ")

oResult := LJCInitialLoadMakerResult():New()

DbSelectArea("MBU")
DbSetOrder(2) // MBU_FILIAL + MBU_TIPO              
If DbSeek(xFilial("MBU") + '2')
	While MBU->(!EOF()) .AND. MBU->MBU_FILIAL + MBU_TIPO == xFilial("MBU") + '2'
		
		oTransferTable := LOJA1156RTG( MBU->MBU_CODIGO ) //array de tabelas transferiveis para a carga (MBU_CODIGO)
		oTransferFiles := LJCInitialLoadMakerTransferFiles():New()
	
		//Para cada tabela transferivel verifica quais filiais vai transferir e define os arquivos da transferencia
		//as exportacoes completa e especial sao quebradas por filial. A exportacao parcial nao gera MBX (filial) 
		For nCountTable := 1 to Len( oTransferTable:aoTables ) 
			
			DO CASE
				CASE Lower(GetClassName( oTransferTable:aoTables[nCountTable] )) == Lower("LJCInitialLoadCompleteTable")
					//oTransferTable:aoTables[nCountTable] -> oCompleteTable
					For nCountBranche := 1 to Len ( oTransferTable:aoTables[nCountTable]:aBranches )
						oFile := LJCInitialLoadMakerTransferFile():New(oTransferTable:aoTables[nCountTable]:cTable, cEmpAnt, oTransferTable:aoTables[nCountTable]:aBranches[nCountBranche] )
						oFile:nRecords := Posicione("MBX", 1, XFilial("MBX") + MBU->MBU_CODIGO + oTransferTable:aoTables[nCountTable]:cTable + oTransferTable:aoTables[nCountTable]:aBranches[nCountBranche] , "MBX_QTDREG")
						oTransferFiles:AddFile(oFile)
					Next
		
				CASE Lower(GetClassName( oTransferTable:aoTables[nCountTable] )) == Lower("LJCInitialLoadPartialTable")
					//oTransferTable:aoTables[nCountTable] -> oPartialTable
					oFile := LJCInitialLoadMakerTransferFile():New(oTransferTable:aoTables[nCountTable]:cTable, cEmpAnt, "" )
					oFile:nRecords := oTransferTable:aoTables[nCountTable]:cQtyRecords
					oTransferFiles:AddFile(oFile)
		
				CASE Lower(GetClassName( oTransferTable:aoTables[nCountTable] )) == Lower("LJCInitialLoadSpecialTable")
					//oTransferTable:aoTables[nCountTable] -> oSpecialTable
					For nCountBranche := 1 To Len( oTransferTable:aoTables[nCountTable]:aParams[1] )
						oFile := LJCInitialLoadMakerTransferFile():New(oTransferTable:aoTables[nCountTable]:cTable, cEmpAnt, oTransferTable:aoTables[nCountTable]:aParams[1][nCountBranche] )
						oFile:nRecords := Posicione("MBX", 1, XFilial("MBX") + MBU->MBU_CODIGO + oTransferTable:aoTables[nCountTable]:cTable + oTransferTable:aoTables[nCountTable]:aParams[1][nCountBranche] , "MBX_QTDREG")
						oTransferFiles:AddFile(oFile)
					Next
					
			ENDCASE
			
		Next
		

		oGroup := LJCInitialLoadGroupConfig():New(oTransferFiles, oTransferTable, TMKDateTime():This(MBU->MBU_DATA,MBU->MBU_HORA), LJILRealDriver(), IIf( ExistFunc("LJILRealExt") , LJILRealExt() , GetDBExtension() )	, MBU->MBU_ORDEM , MBU->MBU_INTINC, MBU->MBU_CODIGO , MBU->MBU_NOME , MBU->MBU_DESCRI, MBU->MBU_CODTPL )
	
		oResult:AddGroup(oGroup)
	
		MBU->( DbSkip() )
	End

	cLastOrder := LJILLastOrderLoad()
	For nI := Len(oResult:aoGroups) to 1 Step -1
		//soh atualiza se a chamada vier da delecao com restauracao da msexp (pra voltar a ordem), ou se for com uma ordem maior que a ultima)
		If oResult:aoGroups[nI]:cEntireIncremental == "2" .AND. ( lUpdateOrderLoad .OR. oResult:aoGroups[nI]:cOrder > cLastOrder )  
			WLastIncOrder(oResult:aoGroups[nI]:cOrder ) //grava a ordem da ultima carga incremental disponivel
			Exit
		EndIf
	Next nI	
	
EndIf

LJPersistObject( oResult:ToXML(.F.), cEmpAnt + "LJCInitialLoadMakerResult", oLJILConfiguration:GetILPersistPath() )

Return oResult


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Classe: ³ LJCInitialLoadMakerConsoleUI      ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Classe para a exibição do progresso da geração da carga para console.  º±±
±±º             ³                                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Class LJCInitialLoadMakerConsoleUI
	Method New()
	Method Update()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Método: ³ New                               ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Construtor.                                                            º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ Nenhum.                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nil                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New() Class LJCInitialLoadMakerConsoleUI
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º     Método: ³ Update                            ³ Autor: Vendas CRM ³ Data: 07/02/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  Descrição: ³ Exibe no console o progresso da geração de carga.                      º±±
±±º             ³                                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametros: ³ oLJInitialLoadMakerProgress: Objeto LJCInitialLoadMakerProgress        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º    Retorno: ³ Nil                                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Update( oLJInitialLoadMakerProgress ) Class LJCInitialLoadMakerConsoleUI
	Local cOut := ""
	Do Case
		Case oLJInitialLoadMakerProgress:nStatus == 1
			cOut += STR0004 + " - " // "Iniciado"
		Case oLJInitialLoadMakerProgress:nStatus == 2
			cOut += STR0005 + " - " // "Exportando"
		Case oLJInitialLoadMakerProgress:nStatus == 3
			cOut += STR0006 + " - " // "Compactando"
		Case oLJInitialLoadMakerProgress:nStatus == 4
			cOut += STR0007 + " - " // "Finalizado"
	EndCase
	
	If ValType(oLJInitialLoadMakerProgress:aTables) != "U"
		If Len(oLJInitialLoadMakerProgress:aTables) > 0 .And. (oLJInitialLoadMakerProgress:nActualTable >= 0 .And. oLJInitialLoadMakerProgress:nActualTable <= Len(oLJInitialLoadMakerProgress:aTables) )
			cOut += oLJInitialLoadMakerProgress:aTables[oLJInitialLoadMakerProgress:nActualTable] + " (" + AllTrim(Str(oLJInitialLoadMakerProgress:nActualTable)) + "/" + AllTrim(Str(Len(oLJInitialLoadMakerProgress:aTables))) + ")" + " - "
		EndIf
	EndIf
	
	If ValType( oLJInitialLoadMakerProgress:nActualRecord ) != "U" .And. ValType(oLJInitialLoadMakerProgress:nTotalRecords) != "U"
		If oLJInitialLoadMakerProgress:nActualRecord > 0 .And. oLJInitialLoadMakerProgress:nTotalRecords > 0
			cOut += AllTrim(Str(oLJInitialLoadMakerProgress:nActualRecord)) + "/" + AllTrim(Str(oLJInitialLoadMakerProgress:nTotalRecords)) + " (" + AllTrim(Str(Round((oLJInitialLoadMakerProgress:nActualRecord*100)/oLJInitialLoadMakerProgress:nTotalRecords,2))) + "%)" + " - "
		EndIf
	EndIf
	
	If ValType( oLJInitialLoadMakerProgress:nRecordsPerSecond ) != "U"
		cOut += AllTrim(Str(oLJInitialLoadMakerProgress:nRecordsPerSecond)) + "r/s"
	EndIf
	
	ConOut( cOut )
Return

//------------------------------------------------------------------------------   
/*/{Protheus.doc} LJGetSvSx8
Obtem a quantidade de números reservados que estão na pilha, referente ao controle de semaforo.
Funcao utilizada para controle de semaforo (Numeracao de Sequencia da Carga - campo "MBU_CODIGO")

@author  Varejo
@version P11.8
@since   16/04/2015
@return	 Quantidade de números reservados que estão na pilha ainda nao confirmados pela funcao ConfirmSx8()
@obs     
@sample
/*/
//------------------------------------------------------------------------------  
Function LJGetSvSx8()
Return nSaveSx8

//------------------------------------------------------------------------------   
/*/{Protheus.doc} LJSetSvSx8
Seta a quantidade de números reservados que estão na pilha referente ao controle de semaforo.
Funcao utilizada para controle de semaforo (Numeracao de Sequencia da Carga - campo "MBU_CODIGO")

@param	 nNumSx8 - Quantidade de números reservados que estão na pilha referente ao controle de semaforo (Padrao: GetSx8Len())
@author  Varejo
@version P11.8
@since   16/04/2015
@return	 Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------  
Function LJSetSvSx8(nNumSx8)
Default nNumSx8 := GetSx8Len()

nSaveSx8 := nNumSx8

Return Nil
