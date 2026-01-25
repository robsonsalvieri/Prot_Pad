#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFINTEGRA.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±         
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse    ³LJCCargaGenerica      ºAutor  ³Vendas Clientes     º Data ³28/09/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Classe com funcionalidade de carga genérica de 1 entidade.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                         		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Class LJCCargaProduto From LJACarga
	Data cProcess		// Processa que da carga a ser efetuada
	
	Method New()
	Method Execute()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³New       ºAutor  ³Vendas Clientes     º Data ³  27/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Construtor da classe LJCCargaGenerica.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto									   				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New( cProcess ) Class LJCCargaProduto
	Self:cProcess := cProcess
	_Super:New()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Execute   ºAutor  ³Vendas Clientes     º Data ³  27/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a carga inicial dos processos e tabelas cadastrados º±±
±±º          ³na tabela MDP, MDO.                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³															  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto									   				  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Execute() Class LJCCargaProduto	
	Local oProcTables		:= Nil
	Local oTables			:= Nil
	Local nTabela			:= 0	
	Local lHaveSB1			:= .F.
	Local lHaveSBM			:= .F.
	Local oEntidadeFactory	:= Nil
	Local oEntidadeSB1		:= Nil	
	Local oEntidadeSBM		:= Nil
	Local oRecords			:= Nil
	Local oSubRecords		:= Nil
	Local oAdapterFactory	:= Nil	
	Local oAdapter			:= Nil	
	Local nCount			:= 0
	
	oProcTables := LJCEntTabProcInt():New()  
	oProcTables:DadosSet( "MDP_PROCES", Self:cProcess )
	oTables := oProcTables:Consultar( 1 )
	
	// Atualiza progresso
	Self:nTotal := 1
	Self:nValue := 0
	// Avisa todas as classes que observam essa, que algo foi atualizado
	Self:Notify()		
	
	For nTabela := 1 To oTables:Count()
		Do Case
			Case oTables:Elements(nTabela):DadosGet("MDP_TABELA") == "SB1"
				lHaveSB1 := .T.
			Case oTables:Elements(nTabela):DadosGet("MDP_TABELA") == "SBM"
				lHaveSBM := .T.
		EndCase
	Next
	
	If lHaveSB1
		// Atualiza o texto do progresso
		Self:cProgressText := "SB1"		
		// Avisa todas as classes que observam essa, que algo foi atualizado
		Self:Notify()										
		
		// Pega a classe de manuseio da tabela
		oEntidadeFactory := LJCEntidadeFactory():New()
		oEntidadeSB1 := oEntidadeFactory:Create( "SB1" )		
		
		// Cria o adaptador de envio utilizando o factory para isso
		oAdapterFactory := LJCAdapXmlEnvFactory():New()
		oAdapter := oAdapterFactory:CreateByProcess( Self:cProcess )	
		
		If oEntidadeSB1 != NIL
			oRecords	:= oEntidadeSB1:Consultar(1)
			
			// Atualiza progresso do item
			Self:nItemTotal := oRecords:Count()
			Self:nItemValue := 0
			// Avisa todas as classes que observam essa, que algo foi atualizado
			Self:Notify()			
			
			// Para cada registro
			For nCount := 1 To oRecords:Count()			
				oAdapter := oAdapterFactory:CreateByProcess( Self:cProcess )	
				If lHaveSBM					
					oEntidadeSBM := oEntidadeFactory:Create( "SBM" )
					
					If oEntidadeSBM != Nil
						oEntidadeSBM:DadosSet( "BM_GRUPO", oRecords:Elements( nCount ):DadosGet( "B1_GRUPO" ) )
						oSubRecords := oEntidadeSBM:Consultar(1)
						
						// Insere os registros no adapter e envia pro EAI.
						If oAdapter != NIL	.And. oSubRecords:Count() > 0
							//Insere os dados da carga
							oAdapter:Inserir( "SBM", oSubRecords:Elements( 1 ):DadosGet( "BM_FILIAL" ) + oSubRecords:Elements( 1 ):DadosGet( "BM_GRUPO" ) , "1", _INCLUSAO)
						EndIf 						
					EndIf				
				EndIf  
				
				// Insere os registros no adapter e envia pro EAI.
				If oAdapter != NIL			
					//Insere os dados da carga
					oAdapter:Inserir( "SB1", oRecords:Elements( nCount ):DadosGet( "B1_FILIAL" ) + oRecords:Elements( nCount ):DadosGet( "B1_COD" ) , "1", _INCLUSAO)
					//Gera carga
					oAdapter:Gerar()
					//Finaliza carga
					oAdapter:Finalizar()					
				EndIf 
				
				If Self:lCancel
					Return .F.
				EndIf				
				
				// Atualiza progresso do item
				Self:nItemValue := nCount								
				// Avisa todas as classes que observam essa, que algo foi atualizado			
				Self:Notify()				
			Next						
			
			// Atualiza progresso do item
			Self:nItemTotal := 0
			Self:nItemValue := 0
			// Avisa todas as classes que observam essa, que algo foi atualizado			
			Self:Notify()				
		EndIf
	EndIf
	
	// Atualiza progresso
	Self:nTotal := 0
	Self:nValue	:= 0
	// Avisa todas as classes que observam essa, que algo foi atualizado				
	Self:Notify()	
Return .T.