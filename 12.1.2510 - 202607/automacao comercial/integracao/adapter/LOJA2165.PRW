#INCLUDE "PROTHEUS.CH"
#INCLUDE "DEFINTEGRA.CH"

Function LOJA2165 ; Return	// "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ         
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออปฑฑ
ฑฑบClasse    ณLJCCargaGenerica      บAutor  ณVendas Clientes     บ Data ณ28/09/09 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออนฑฑ
ฑฑบDesc.     ณClasse com funcionalidade de carga gen้rica de 1 entidade.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                         		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCCargaGenerica From LJACarga
	Data cProcess		// Processa que da carga a ser efetuada
	
	Method New()
	Method Execute()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณNew       บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstrutor da classe LJCCargaGenerica.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New( cProcess ) Class LJCCargaGenerica
	Self:cProcess := cProcess
	_Super:New()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณExecute   บAutor  ณVendas Clientes     บ Data ณ  27/03/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta a carga inicial dos processos e tabelas cadastrados บฑฑ
ฑฑบ          ณna tabela MDP, MDO.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณObjeto									   				  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method Execute() Class LJCCargaGenerica
	Local oProcTables		:= Nil
	Local oTables			:= Nil
	Local nTabela			:= 0
	Local cTable			:= ""
	Local oEntidadeFactory	:= Nil
	Local oEntidade			:= Nil
	Local oAdapterFactory	:= Nil
	Local oIndice			:= Nil	
	Local oIndices			:= Nil	
	Local nCount			:= 0
	Local oAdapter			:= Nil
	Local cChave			:= ""
	Local oRecords			:= Nil	
	
	// Consulta as tabelas do processo
	oProcTables := LJCEntTabProcInt():New()  
	oProcTables:DadosSet( "MDP_PROCES", Self:cProcess )
	oTables := oProcTables:Consultar( 1 )
	
	Self:nTotal := oTables:Count()
	Self:nValue := 0
	
	For nTabela := 1 To oTables:Count()

		// Pega a tabela em processo
		cTable := oTables:Elements(nTabela):DadosGet("MDP_TABELA")
		
		Self:cProgressText := cTable
		
		// Avisa todas as classes que observam essa, que algo foi atualizado
		Self:Notify()						

		// Pega a classe de manuseio da tabela
		oEntidadeFactory := LJCEntidadeFactory():New()
		oEntidade := oEntidadeFactory:Create( cTable )
		
		If oEntidade != NIL
			oRecords	:= oEntidade:Consultar(1)		
			
			// Monta a chave primแria		
			oIndices	:= oEntidade:Indices()		
			oIndice		:= oIndices:Elements(1)
			cChave := ""
			For nCount := 1 To oIndice:Campos():Count()
				cChave += "oRecords:Elements(nCount):DadosGet(oIndice:Campos():Elements(" + AllTrim(Str(nCount)) + "))" + If(nCount == oIndice:Campos():Count(), "", "+")
			Next		
			cChave := "Eval({||" + cChave + "})"
			
			Self:nItemTotal := oRecords:Count()
			Self:nItemValue := 0
			// Avisa todas as classes que observam essa, que algo foi atualizado
			Self:Notify()			
			
			// Para cada registro
			For nCount := 1 To oRecords:Count()

				
				// Cria o adaptador de envio utilizando o factory para isso
				oAdapterFactory := LJCAdapXmlEnvFactory():New()
				oAdapter := oAdapterFactory:Create( cTable )
				
				// Todo: Precisa tirar, pois fiz s๓ para facilitar o teste
				If cTable == "SX5" .And.;
					!( ;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "V0" .Or.;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "T2" .Or.;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "24" .Or.;
						AllTrim(oRecords:Elements(nCount):DadosGet("X5_TABELA")) == "12" ;
					)
					Loop
				EndIf
				
				// Insere os registros no adapter e envia pro EAI.
				If oAdapter != NIL			
					//Insere os dados da carga
					oAdapter:Inserir( cTable, &cChave , "1", _INCLUSAO)
					//Gera carga
					oAdapter:Gerar()
					//Finaliza carga
					oAdapter:Finalizar()					
				EndIf 
				
				If Self:lCancel
					Return .F.
				EndIf
				
				Self:nItemValue := nCount  
				// Avisa todas as classes que observam essa, que algo foi atualizado
				Self:Notify()								
				
			Next    
			
			Self:nItemTotal := 0
			Self:nItemValue := 0
			// Avisa todas as classes que observam essa, que algo foi atualizado			
			Self:Notify()							
		EndIf 
		
		Self:nValue := nTabela 
		// Avisa todas as classes que observam essa, que algo foi atualizado			
		Self:Notify()											 
	Next
	Self:nTotal := 0
	Self:nValue	:= 0
	// Avisa todas as classes que observam essa, que algo foi atualizado				
	Self:Notify()
Return .T.