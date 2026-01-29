#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1146.CH"

#DEFINE ENTIRE		"1"  //carga inteira
#DEFINE INCREMENTAL	"2"  //carga incremental


// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1146() ; Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadMaker

Classe responsável por gerar e disponibilizar a carga
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Class LJCInitialLoadMaker
	Data cRootPath
	Data oTransferTables
	Data aoObservers
	Data oProgress
	Data cExportType 		//(inteira ou incremental) 
	Data cCodInitialLoad 	//MBU_CODIGO - da carga em si (nao do template)
	Data aExec
	Data nExtFile
	Data nProxArq
	Data cTabela
	Data cEmpresa
	Data cFilialArq
	Data aEstrutura
	Data cTabRastro
	Data aExpTemp
	Data oTabExc

	Method New()                                         		
	Method SetTransferTables()
	Method Execute()
	Method CheckPath()
	Method ClearPath()
	Method IsTableShared()
	Method ExportComplete()
	Method ExportPartial()
	Method ExportSpecial()	
	Method Compact()
	Method AddObserver()
	Method Notify()
	Method SetExportType()
	Method SetCodInitialLoad()
	Method UpdateQtyRecExport()
	Method RemoveLoadRecord()
	Method RemoveWithoutRecord()
	Method GeraStrCSV() 
	Method GeraDadoCSV()
	Method CloseArqCSV()        
	Method GetQtyRecExport()	
	Method AtlzMsExp()
	Method TamArquivo()
	Method CamRootPath()
	Method NovoArquivo()
	Method TabMsExp()
	Method ValidaCsv()
	
EndClass        


//--------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor

@param cRootPath Caminho onde será armazenado a carga gerada. 

@return Self

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method New( cRootPath ) Class LJCInitialLoadMaker
	Self:cRootPath	:= cRootPath
	Self:CheckPath()
	Self:aoObservers:= {}
	Self:oProgress	:= LJCInitialLoadMakerProgress():New( -1 )
	Self:aExec		:= {}
	Self:nExtFile	:= SuperGetMV("MV_LJTFILE",.F.,0)
	Self:nProxArq	:= 0
	Self:cTabRastro	:= SuperGetMv("MV_LJLOGCA",.F.,"")
	Self:aExpTemp	:= {}

	Self:oTabExc	:= FWTemporaryTable():New(GetNextAlias())
	Self:oTabExc:SetFields({{"TABELA","C",3,0},{"RECNO","C",16,0}})
	Self:oTabExc:AddIndex("1", {"TABELA","RECNO"})
	Self:oTabExc:Create()


Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} CheckPath()

Valida o caminho informado, se o caminho não existir, ele cria. 

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method CheckPath() Class LJCInitialLoadMaker
	Local oLJCMessageManager := GetLJCMessageManager()
	Self:cRootPath := If( Right( Self:cRootPath,1) != If( IsSrvUnix(), "/", "\" ) , Self:cRootPath += If( IsSrvUnix(), "/", "\" ) , Self:cRootPath )
	
	If !ExistDir( Self:cRootPath )
		If MakeDir( Self:cRootPath ) != 0
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadIOMessage", 1, STR0001 + " '" + Self:cRootPath + "'.") ) // "Não foi possível criar o diretório"
		EndIf
	EndIf

	//-- Cria o diretório de backup para fazer a comparação dos registros antes de atualizar o _MSEXP
	If !ExistDir( Self:cRootPath + "backup\")
		If MakeDir( Self:cRootPath + "backup\" ) != 0
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadIOMessage", 1, STR0001 + " '" + Self:cRootPath + "Backup\'.") ) // "Não foi possível criar o diretório"
		EndIf
	EndIf

Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ClearPath()

Apaga os arquivo existentes no diretório do caminho informado

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method ClearPath( lDelDir ) Class LJCInitialLoadMaker
	Local oLJCMessageManager := GetLJCMessageManager()
	Local aDir				:= {}
	Local nCount			:= 1
	
	Default lDelDir 	 	:= .F.
	
	Self:CheckPath()		
	
	If !oLJCMessageManager:HasError()
		aDir := Directory( Self:cRootPath + "*.*" )
		
		For nCount := 1 To Len( aDir )		
			If FErase( Self:cRootPath + aDir[nCount][1] ) != 0
				oLJCMessageManager:ThrowMessage( LJCMessage():New("LJInitialLoadIOMessage", 1, STR0002 + " '" + Self:cRootPath + aDir[nCount][1] + "'." ) ) // "Não foi possível apagar o arquivo temporário"
				lDelDir := .F.
				Exit
			EndIf
		Next
		
		If lDelDir
			DirRemove(Self:cRootPath)
		EndIf
		
	EndIf
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} IsTableShared()

Retorna se a tabela passada por parâmetro é compartilhada ou não

@param cTableName Nome da tabela

@return lRet: .T. tabela compartilhada, .F. tabela exclusiva.  

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method IsTableShared( cTableName ) Class LJCInitialLoadMaker
	Local lRet				:= .F.
	Local oLJCMessageManager	:= GetLJCMessageManager()

	DbSelectArea( "SX2" )
	If DbSeek( cTableName )
		If AllTrim(Upper(FWModeAccess(FWX2Chave(),3))) == "C"
			lRet := .T.
		EndIf
	Else
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadInvalidTableName", 1, STR0003 + " " + Self:cTableName + " " + STR0004 ) ) // "Tabela" "não existe no SX2."
	EndIf	
Return lRet


//--------------------------------------------------------------------------------
/*/{Protheus.doc} SetTransferTables()

Configura as tabelas que deverão ter suas cargas geradas. 

@param oTransferTables Objeto do tipo LJCInitialLoadTransferTables

@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method SetTransferTables( oTransferTables ) Class LJCInitialLoadMaker
	Self:oTransferTables := oTransferTables
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} Compact()

Compacta a tabela e filial exportada.       

@param cFileNamePath caminho do arquivo

@return cRet Nome do arquivo compactado

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method Compact( cFileNamePath ) Class LJCInitialLoadMaker
	Local aFiles				:= {}
	Local aDir					:= {}
	Local nCount 				:= 1
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local nX					:= 0
	Local nI					:= 0
	
	// Avisa a todos os interessando o progresso da geração da carga inicial			
	Self:oProgress:nStatus := 3
	Self:Notify()	
	
	// Garante que o mzp não existe
	If File(Self:cRootPath + cFileNamePath + IIF(Self:nExtFile == 0, ".mzp", ".zip")) 
		LjGrvLog( "Carga","Arquivo ja existe nao sera recriado " + cFileNamePath + ".mzp")
		Return cFileNamePath + ".mzp"	
	EndIf
	
	// Pega os arquivos que compoem a tabela (normalmente é o dbf e um arquivo que contem o memo)
	aDir := Directory( Self:cRootPath + cFileNamePath + ".*" )

	// Tratamento para ambientes Cloud com Ctree Server, onde a criação do arquivo da carga tem um
	// delay na criação e a função Directory não acha o arquivo nesse meio tempo
	If Len(aDir) == 0
		If File(Self:cRootPath + cFileNamePath + ".*")
			Sleep(1000)
			For nX := 1 To 4
				aDir := Directory( Self:cRootPath + cFileNamePath + ".*" )
				If Len(aDir) > 0
					Exit
				EndIf
				Sleep(1000)
			Next
		EndIf
	EndIf

	For nCount := 1 To Len( aDir )
		aAdd( aFiles, Self:cRootPath + aDir[nCount][1] )
	Next
		
	If (ValType(Self:nExtFile) <> "N") .OR. (Self:nExtFile <> 0 .AND. Self:nExtFile <> 1)
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadIOMessage", 1, STR0021 ) ) //"Erro ao compactar arquivo da carga, o parâmetro MV_LJTFILE deve ser do tipo numérico e conter o valor 0 ou 1."
	Else

		//Faz a copia dos arquivos para fazer a blindagem dos registros que estão no arquivo .csv com os registros da tabela temporaria.
		//Essa blindagem serve para não atualizar o campo _MSEXP de algum registro que deveria estar no arquivo .csv mas não esta.
		For nI := 1 To Len(aFiles)
			If __CopyFile(aFiles[nI], Self:cRootPath + "backup\" + cFileNamePath + ".csv")
				If (SubStr(cFileNamePath,1,3) $ Self:cTabRastro)
					LjGrvLog( "Rastro_Carga","Arquivo " + aFiles[nI] + " copiado com sucesso para a pasta de backup.")
				EndIf
			Else
				If (SubStr(cFileNamePath,1,3) $ Self:cTabRastro)
					LjGrvLog( "Rastro_Carga","Não foi possivel copiar o arquivo " + aFiles[nI] + " para a pasta de backup.")
				EndIf
			EndIf
		Next nI

		// Compacta a tabela e elimina os temporários
		If IIF(Self:nExtFile == 0, AllTrim(MsCompress( aFiles, Self:cRootPath + cFileNamePath + ".mzp" )) != "", FZip(Self:cRootPath + cFileNamePath + ".zip", aFiles) == 0)
			For nCount := 1 To Len( aFiles )
				If FErase( aFiles[nCount] ) != 0
					oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadIOMessage", 1, STR0007 + " '" + aFiles[nCount] + "'." ) ) // "Não foi possível apagar o arquivo temporário"
					Exit
				EndIf		
			Next
			LjGrvLog( "Carga","Arquivo compactado com sucesso " + cFileNamePath + ".mzp")
		Else
			oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadIOMessage", 1, STR0008 + " '" + /*cTable + "' " + STR0009 + " '" + cBranch*/ Self:cRootPath + cFileNamePath + "'." ) ) // "Não foi possível compactar a tabela" "filial"
		EndIf	
	EndIf
Return cFileNamePath + IIF(Self:nExtFile == 0, ".mzp", ".zip")



//--------------------------------------------------------------------------------
/*/{Protheus.doc} Export()

Exporta e compacta as tabelas e filials adicionadas

@return lExitCarga - Retorna se criou a carga

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method Execute() Class LJCInitialLoadMaker
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local nCount				:= 0
	Local nCount2				:= 0
	Local aoTransferFiles		:= {}
	Local oResult				:= Nil
	Local nLoadLimit			:= SuperGetMV("MV_LJILQTD", .F., 0)
	Local aLoadDel 				:= {} 
	Local nPos 					:= 0
	Local lExitCarga 			:= .F.
	Local nSaveSx8 				:= 0
	Local lOpenCSV				:= SuperGetMV("MV_LJGECSV",,"0") $ "12" //geracao de CSV 0 - Não gera, 1 - gera dbf/csv, 2 - somente csv 
	Local cRelease				:= GetRPORelease()						//Release atual
	Local lExiste				:= .T.
	Local nContador				:= 1
		
	If MpDicInDb() .AND. cRelease >= "12.1.025" 
		lOpenCSV := .T.
		LjGrvLog( "Carga","Release Atua: " + cRelease + " e Dicionario no banco, parametro MV_LJGECSV obrigatoriamente devera ser igual a '2'")							
	EndIf
	
	// Avisa a todos os interessados que o processo de geração de carga foi iniciado
	Self:oProgress:nStatus := 1	
	Self:Notify()
	
	If !ExistFunc("LjCSVConvtype") .AND. lOpenCSV
		oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakeNoFunction", 1, STR0018 ) ) //"Para a carga CSV é necessário atualizar o Fonte LOJA1144"
	EndIf
	
	//verifica se nao ultrapassou o limite de cargas para nao ultrapassar 1 MB no xml de resultados
	If  LJ1156CountLoads() <= nLoadLimit 
	  
		// Prepara o diretório onde ficará armazenado os arquivos.
		Self:CheckPath()
			
		If !oLJCMessageManager:HasError()
			// Configura o progresso		
			Self:oProgress:aTables := {}
			For nCount := 1 To Len( Self:oTransferTables:aoTables )
				aAdd( Self:oProgress:aTables, Self:oTransferTables:aoTables[nCount]:cTable )
			Next
			
			// Para cada tabela		
			For nCount := 1 To Len( Self:oTransferTables:aoTables )
				Self:oProgress:nActualTable := nCount
				Self:Notify()
				If !oLJCMessageManager:HasError()
					If Lower(GetClassName( Self:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadCompleteTable")
						aoTransferFiles := Self:ExportComplete( Self:oTransferTables:aoTables[nCount] )
					ElseIf Lower(GetClassName( Self:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadPartialTable")
						aoTransferFiles := Self:ExportPartial( Self:oTransferTables:aoTables[nCount] )
					ElseIf Lower(GetClassName( Self:oTransferTables:aoTables[nCount] )) == Lower("LJCInitialLoadSpecialTable")				
						aoTransferFiles := Self:ExportSpecial( Self:oTransferTables:aoTables[nCount] )
					EndIf
			
					If !oLJCMessageManager:HasError() .And. Len(aoTransferFiles) > 0
						For nCount2 := 1 To Len( aoTransferFiles )
							If aoTransferFiles[nCount2]:nRecords > 0
								If (Self:nExtFile == 1) .AND. !(aoTransferFiles[nCount2]:cTable $ "SX5|SX6")
									nContador 	:= 1
									lExiste		:= .T.
									While lExiste
										If File(Self:cRootPath + aoTransferFiles[nCount2]:GetFileWithoutExtension() + "_" + AllTrim(Str(nContador)) + ".csv")
											Self:Compact( aoTransferFiles[nCount2]:GetFileWithoutExtension() + "_" + AllTrim(Str(nContador)))
											nContador++
										Else
											lExiste := .F.
										EndIf
									End
								Else
									Self:Compact( aoTransferFiles[nCount2]:GetFileWithoutExtension() )
								EndIf
								lExitCarga := .T.
							Else
								// Tabela sem registro gerado na carga. Essa tabela deve ser desconsiderada da carga
								If ( nPos := aScan( aLoadDel, {|x| x[1] == aoTransferFiles[nCount2]:cTable } ) ) > 0
									aAdd( aLoadDel[nPos][2], aoTransferFiles[nCount2]:cBranch )
								Else
									aAdd( aLoadDel, { aoTransferFiles[nCount2]:cTable, {aoTransferFiles[nCount2]:cBranch} } )
								EndIf
							EndIf
						Next
					Else//Caso der algum erro, remove os registros da carga (MBU, MBV, etc)
					
						Self:RemoveLoadRecord(Self:cCodInitialLoad)
						Exit
					EndIf				
				EndIf
			Next	
			
			//Exclui os arquivos das tabelas que nao foram gerados registros, e limpa as tabelas
			If Len(aLoadDel) > 0
				Self:RemoveWithoutRecord( Self:cCodInitialLoad, Self:oTransferTables:aoTables, aLoadDel, lExitCarga )
			EndIf
			
			If ExistFunc("LJGetSvSx8")
				//Concluir o tratamento de Controle de Numeracao Gerada para esta carga em questao
				nSaveSx8 := LJGetSvSx8()
				
				DbSelectArea("MBU")
				If lExitCarga //Existe carga gerada para este processo
					//Efetiva a gravação do registro reservado pelo GetSxeNum.
					While ( GetSx8Len() > nSaveSx8 )
						ConfirmSx8()
					End
				Else //Nao existe carga gerada para este processo
					//Libera o registro reservado pelo GetSxeNum.
					While ( GetSx8Len() > nSaveSx8 )
						RollBackSx8()
					End
				EndIf
				
				LJSetSvSx8(0)
			EndIf

			//Se não houve nenhum erro, então atualiza o MSEXP das tabelas.
			If !oLJCMessageManager:HasError()
				Self:AtlzMsExp()
			EndIf
				
		EndIf				
				
		// Avisa a todos os interessados que o processo de geração de carga foi encerrado
		Self:oProgress:nStatus := 4
		Self:Notify()
	
	Else
		Self:RemoveLoadRecord(Self:cCodInitialLoad)
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJInitialLoadMaker", 1, STR0014 ) )  //"Limite de quantidade de cargas atingido. Não será possível gerar a carga. Verifique o parâmetro MV_LJILQTD ou exclua alguma carga ativa"
	
	
	EndIf
						
Return lExitCarga


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ExportComplete()

Exporta a tabela do tipo completa

@param oCompleteTable Objeto do tipo LJCInitialLoadCompleteTable

@return aResults: Array de objetos do tipo LJCInitialLoadMakerTransferFile
com os arquivos criados na geração da carga.
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method ExportComplete( oCompleteTable ) Class LJCInitialLoadMaker
Local aResults			:= {}
Local oResult			:= Nil
Local cFileNamePath		:= "" 
Local aStruct			:= {}
Local nCount			:= 0
Local nCount2			:= 0
Local lRenewTimer		:= .T.
Local nTotalRecords		:= 0
Local nSecond1			:= 0
Local nSecond2			:= 0
Local nRecordsProcessed	:= 0
Local nRecord			:= 0
Local oLJMessageManager	:= GetLJCMessageManager()
Local lLJ1146Ex			:= ExistBlock( "LJ1146Ex" )
Local oTempTable		:= Nil
Local cTablePrefix		:= ""
Local cTypeDB			:= TCGetDB()
Local lLj1170MM			:= ExistBlock("Lj1170MM")
Local nAux				:= 0
Local cGerCSV			:= SuperGetMV("MV_LJGECSV",.F.,"0") //geracao de CSV 0 - Não gera, 1 - gera dbf/csv, 2 - somente csv
Local oFrm				:= NIL //Formulário CSV
Local lGeraCSV			:= (cGerCSV == "1" .OR.  cGerCSV == "2") //Gera o arquivo CSV?
Local cFileNameCSV		:= "" //Nome do arquivo CSV
Local aStruct2			:= {} //Estrutura do Arquivo
Local cFileExt			:= "" //Extensão do arquivo	
Local lFileExists		:= .F.
Local lAlreadyProcess   := .F.
Local lX3_POSLGT		:= SX3->(ColumnPos("X3_POSLGT")) > 0  
Local cRealDrv			:= ""
Local lIsCtree			:= .F.
Local cMthIsMbOf		:= "MethIsMemberOf"
Local lHasNewMet		:= Nil				//indica se o metodo MethIsMemberOf existe no binario
Local cRelease			:= GetRPORelease()	//Release atual
Local lLJ1146GrvC		:= ExistBlock( "LJ1146GrvC") //Ponto de Entrada para gravação de campos 
Local aFieldsTmp		:= {}
Local nPosRec			:= 0 

  
LjGrvLog( "Carga","ExportComplete Inicio")
LjGrvLog( "Carga","P.E LJ1146Ex 	" ,lLJ1146Ex	)
LjGrvLog( "Carga","P.E lLj1170MM 	" ,lLj1170MM	)
LjGrvLog( "Carga","P.E lLJ1146GrvC 	" ,lLJ1146GrvC	)

If MpDicInDb() .AND. cRelease >= "12.1.025"
	lGeraCSV 	:= .T.
	cGerCSV		:= "2"
	LjGrvLog( "Carga","Release Atua: " + cRelease + " e Dicionario no banco, parametro MV_LJGECSV obrigatoriamente devera ser igual a '2'")								
EndIf


If ChkFile( oCompleteTable:cTable, .F. )
	
	// Abre a tabela de origem
	DbSelectArea( oCompleteTable:cTable )

	cTablePrefix := IIf( SubStr(oCompleteTable:cTable,1,1) == "S", SubStr(oCompleteTable:cTable,2,3), oCompleteTable:cTable )

	// Valida a existencia dos campos _MSEXP e _HREXP
	If (oCompleteTable:cTable)->(ColumnPos(cTablePrefix + "_MSEXP")) > 0  .AND. (oCompleteTable:cTable)->(ColumnPos(cTablePrefix + "_HREXP")) > 0

		// Pega a estrutura do banco de dados
		aStruct := (oCompleteTable:cTable)->( DBStruct() )
		//Adiciona na estrutura o campo DEL pra poder controlar os registros deletados
		AADD(aStruct, {"DEL", "C", 1 , 0} )
		AADD(aStruct, {"REC", "C", 16 , 0} )

		cFileExt := IIf( ExistFunc("LJILRealExt") , LJILRealExt() , GetDBExtension() )
		lIsCtree := Lower(cFileExt) == ".dtc"
		cRealDrv := LJILRealDriver()

		// Loop em todas as Filiais
		For nCount := 1 To Len( oCompleteTable:aBranches )
			
			If !oLJMessageManager:HasError()

				oResult := LJCInitialLoadMakerTransferFile():New( oCompleteTable:cTable, cEmpAnt, AllTrim(oCompleteTable:aBranches[nCount]) )
				nRecord := 0

				Self:nProxArq 	:= 1
				Self:cTabela	:= oCompleteTable:cTable
				Self:cEmpresa	:= cEmpAnt
				Self:cFilialArq	:= AllTrim(oCompleteTable:aBranches[nCount])
				Self:aEstrutura	:= aClone(aStruct)

				//Se vai exportar tabela temporaria
				If cGerCSV <> "2"
					cFileNamePath := Self:cRootPath + oResult:GetFileWithoutExtension() + cFileExt
					If !File(cFileNamePath) .AND. !File(Left(cFileNamePath, Len(cFileNamePath)-3)+"mzp")
						//Caso o PE LJ1146Ex esteja presente, utiliza o modo antigo de geracao do TRB (linha-a-linha)
						If lLJ1146Ex .OR. lIsCtree
							//Cria o arquivo fisico TRB
							DbCreate( cFileNamePath, aStruct, LJILRealDriver() )
						EndIf
					Else
						//Arquivo pré existente, resulta de erro em operação anterior
						LjGrvLog( "Carga","Arquivo ja existe " + cFileNamePath)
						lFileExists := .T.
					EndIf
				EndIf

				lAlreadyProcess := .F.

				// Criacao do arquivo CSV				
				If lGeraCSV
					aStruct2 := {}
					cFileNameCSV := Self:cRootPath + oResult:GetFileWithoutExtension() + IIF(Self:nExtFile == 1, "_" + AllTrim(Str(Self:nProxArq)), "") +".csv"
					oFrm := Self:GeraStrCSV(lGeraCSV, aStruct, cFileNameCSV, @aStruct2)
				EndIf	

				// Se exportacao de tabela temporaria (modo legado obriga o arquivo existir, modo novo, obriga a pasta da carga existir) e/ou gera CSV
				If ( cGerCSV <> "2" .AND. IIf(lFileExists .OR. lLJ1146Ex, File(cFileNamePath), ExistDir(Self:cRootPath)) ) .OR. lGeraCSV

					// Se exportacao de tabela temporaria, faz a sua abertura
					If cGerCSV <> "2" .AND. (lLJ1146Ex .OR. lFileExists .OR. lIsCtree)
						DbUseArea( .T., LJILRealDriver(), cFileNamePath, "TRB", .F., .F. )
					EndIf
						
					If ( cGerCSV <> "2" .AND. IIf(lFileExists .OR. lLJ1146Ex .OR. lIsCtree, TRB->(Used()), .T.) ) .OR. lGeraCSV
								
						Self:oProgress:nStatus := 5	//Analisando tabela a exportar
						Self:Notify()

						// Cria a estrutura da tabela temporaria que sera usada como base para exportacao
						oTempTable := LJCInitialLoadTempTableExport():New(oCompleteTable, oCompleteTable:aBranches[nCount], Self:cExportType, "TABTMP")
						
						// Usamos a comparacao com Nil por causa que oTempTable so pode ser instanciada dentro do loop,
						// entao apos "lHasNewMet" ser atribuida pela primeira vez, a funcao MethIsMemberOf nao sera mais chamado						
						If lHasNewMet == Nil
							If ExistFunc(cMthIsMbOf)
								lHasNewMet := &cMthIsMbOf.( oTempTable, "SetQtyRecSQL" )
							Else
								lHasNewMet := .F.								
							EndIf
							LjGrvLog( "Carga","O metodo SetQtyRecSQL(LOJA1170.PRW) EXISTE?", lHasNewMet)
						EndIf

						// alimenta a tabela com os dados
						oTempTable:CreateTempTable()
						
						/* 
						   Para cada tabela do pacote da carga é criado uma tabela temporaria no banco de dados,
						   essa tabela temporaria recebe todos os registros que foram incluídos no arquivo .csv para
						   posteriormente atualizar os campos MSEXP e HREXP da tabela de dados que foi gerada a carga.

						   Estrutura do array Self:aExpTemp:
						   [1] - Alias da tabela temporia
						   [2] - Objeto da tabela temporia criada a partir do FWTemporaryTable
						   [3] - Tabela do banco da qual esta sendo exportado os dados.
						   [4] - Endereço e nome do arquivo referente a tabela

						   A atualização do MSEXP e HREXP é realizado através do metodo AtlzMsExp
						*/
						If Len(Self:aExpTemp) == 0 .OR. Self:aExpTemp[Len(Self:aExpTemp)][3] <> oCompleteTable:cTable
							aFieldsTmp 	:= TABTMP->(dbStruct())
							nPosRec 	:= aScan(aFieldsTmp,{|x| x[1] == "REC"})
							
							/*
								Estava ocorrendo erro de estouro de campo ao incluir os dados da tabela fisica na tabela temporaria,
								esse erro acontecia no campo RECNO. Em conversa com o FrameWork nos orientaram a tratar o campo RECNO na tabela temporaria como caractere porque
								o ADVPL não tem o mesmo tipo de campo (BigInt). 
							*/
							aFieldsTmp[nPosRec][2] := "C"
							aFieldsTmp[nPosRec][3] := 16
							aFieldsTmp[nPosRec][4] := 0

							aADD(Self:aExpTemp, {GetNextAlias(),Nil,oCompleteTable:cTable,oFrm[4]})
							Self:aExpTemp[Len(Self:aExpTemp)][2] := FWTemporaryTable():New( Self:aExpTemp[Len(Self:aExpTemp)][1], aFieldsTmp)
							Self:aExpTemp[Len(Self:aExpTemp)][2]:AddIndex("1", {"REC"})
							Self:aExpTemp[Len(Self:aExpTemp)][2]:Create()
						Else
							Self:aExpTemp[Len(Self:aExpTemp)][4] += ";" + oFrm[4]
						EndIf

						// Se houver um Filtro, ele é aplicado sobre o result set (se existisse uma funcao que convertesse o filtro em uma expressao SQL, esse trecho nao seria necessario)
						If !Empty( oCompleteTable:cFilter ) .AND. !Empty(ALLTRIM(STRTran(oCompleteTable:cFilter,chr(13)+chr(10),"")))
							TABTMP->( DBSetFilter({|| &(oCompleteTable:cFilter)}, oCompleteTable:cFilter) )
							oTempTable:SetQtyRecords()
						ElseIf lHasNewMet
							// faz a contagem dos registros via Count(SQL)
							oTempTable:SetQtyRecSQL()
						Else
							oTempTable:SetQtyRecords()
						EndIf

						nTotalRecords := oTempTable:nQtyRecords
						Self:oProgress:nTotalRecords := nTotalRecords																											
						Self:oProgress:nStatus := 2		//Exportando

						// Exporta os registros
						Dbselectarea("TABTMP")
						TABTMP->( DbGoTop() )

						If lFileExists
						
							LjGrvLog( "Carga","recupera arquivo ja iniciado" )

							TRB->( DbGoBottom() )
							nTotalRecords := TRB->(Recno())
							nRecord := nTotalRecords

							//Verifica se concluiu a carga para tabela antes do erro
							If oTempTable:nQtyRecords <> 0 .And. nTotalRecords <> oTempTable:nQtyRecords
								//Recria tabela tamporaria se processo foi interrompido
								TRB->(DbCloseArea())
								FErase(cFileNamePath)									
								DbCreate( cFileNamePath, aStruct, LJILRealDriver() )                                                                                                                                     		
								DbUseArea( .T., LJILRealDriver(), cFileNamePath, "TRB", .F., .F. )

								nTotalRecords := oTempTable:nQtyRecords
								nRecord := 0
							ElseIf nRecord == oTempTable:nQtyRecords
								lAlreadyProcess := .T.
							EndIf
						EndIf

						Self:oProgress:nTotalRecords := nTotalRecords
						Self:oProgress:nStatus := 2		//Exportando

						LjGrvLog("Carga", "Geracao TRB registro a registro")
						While TABTMP->(!EoF()) .AND. !lAlreadyProcess

							nRecord++

							If lLJ1146Ex
								If !ExecBlock( "LJ1146Ex", .F., .F., { oCompleteTable:cTable, oCompleteTable:aBranches[nCount] } )
									TABTMP->(DbSkip())
									Loop
								EndIf
							EndIf

							If lRenewTimer
								nSecond1			:= Seconds()
								nRecordsProcessed	:= 0
								lRenewTimer 		:= .F.
							EndIf			

							If cGerCSV <> "2" 
								RecLock( "TRB", .T. )
								For nCount2 := 1 To Len(aStruct)
									If aStruct[nCount2][1] == cTablePrefix + "_MSEXP"
										TRB->(FieldPut(ColumnPos(aStruct[nCount2][1]) , DtoS(dDataBase) ))					
									ElseIf aStruct[nCount2][1] == cTablePrefix + "_HREXP"
										TRB->(FieldPut(ColumnPos(aStruct[nCount2][1]) , Left(Time(),8) ))					
									Else
										//a verificacao do GetSx3Cache eh para saber se o registro pode entrar na carga.
										//Util quando se utiliza campo memo, que tem um tamanho consideravel e lerdeia a geracao
										//da carga.
										//Verifica se eh campo MEMO Real
										If lX3_POSLGT .And. aStruct[nCount2][2] == "M" .AND. GetSx3Cache( aStruct[nCount2][1],"X3_POSLGT") <> "2"

											If lLj1170MM
												If !Empty(ExecBlock("Lj1170MM",.F.,.F.,{oCompleteTable:cTable,aStruct[nCount2][1]}))
													TRB->(FieldPut(ColumnPos(aStruct[nCount2][1]) , TABTMP->(FieldGet(ColumnPos( aStruct[nCount2][1]) ))))
												EndIf
											Else
												If "MSSQL" $ cTypeDB
													TRB->(FieldPut(ColumnPos(aStruct[nCount2][1]) , TABTMP->(FieldGet(ColumnPos( aStruct[nCount2][1]) ))))
												ElseIf "DB2" $ cTypeDB
													nAux := TABTMP->((ColumnPos( aStruct[nCount2][1]) ))
													If nAux > 0		// Há campos memo não encontrados na tabela DB2.
														TRB->(FieldPut(ColumnPos(aStruct[nCount2][1]) , TABTMP->(FieldGet( nAux ))))
													EndIf
												EndIf
											EndIf
										Else
											If !Empty(TABTMP->(FieldGet(ColumnPos( aStruct[nCount2][1]) )))
												TRB->(FieldPut(ColumnPos(aStruct[nCount2][1]) , TABTMP->(FieldGet(ColumnPos( aStruct[nCount2][1]) ))))
											EndIf
										EndIf
									EndIf
								Next nCount2
								
								TRB->( MsUnLock() )
							EndIf			

							//Geração de dados em csv								
							Self:GeraDadoCSV(lGeraCSV, aStruct2, cTablePrefix,"TABTMP", @oFrm)
			
							nSecond2 := Seconds()
			
							If nSecond2 - nSecond1 >= 1
								lRenewTimer := .T.
								// Avisa a todos os interessando o progresso da geração da carga inicial			
								Self:oProgress:nActualRecord := nRecord
								Self:oProgress:nRecordsPerSecond := Int( nRecordsProcessed / (nSecond2-nSecond1) )
								Self:Notify()
							EndIf

							TABTMP->( DbSkip() )
							nRecordsProcessed++
						End

						Self:CloseArqCSV(lGeraCSV, @oFrm)

						//Atualiza a quantidade de registros exportados na MBV
						Self:UpdateQtyRecExport(oCompleteTable, oCompleteTable:aBranches[nCount], nRecord)

						// Avisa a todos os interessando o progresso da geração da carga inicial
						Self:oProgress:nActualRecord := nRecord
						Self:oProgress:nRecordsPerSecond := Int( nRecordsProcessed / (nSecond2-nSecond1) )
						Self:Notify()

						If cGerCSV <> "2" .AND. (lLJ1146Ex .OR. lIsCtree .OR. lFileExists)
							TRB->(DbCloseArea())
						EndIf

						If !oLJMessageManager:HasError()
							oResult:nRecords := nRecord
							aAdd( aResults, oResult )
						EndIf

						//Se for a primeira exportacao da tabela ou for incremental, atualiza os campos MSEXP dos registros exportados 
						If ( oTempTable:IsFirstExport() ) .OR. ( Self:cExportType == INCREMENTAL )
							Self:oProgress:nStatus := 6	//"Atualizando Registros Exportados"
							Self:Notify()	
							Aadd(Self:aExec, oTempTable:UpdateMSEXP())
						EndIf
						
						Self:TabMsExp() 
						TABTMP->( dbCloseArea() ) 
					Else
						oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotOpenCreatedTable", 1, STR0010 + " '" + cFileNamePath + "'. " + STR0011) ) // "O arquivo de dados foi criado, mas não foi possível sua abertura " "O driver utilizado pode estar errado."
					EndIf
				Else
					If !lFileExists
						oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotCreateTable", 1, STR0012 + " '" + cFileNamePath + "'. " + STR0013) ) // "Não foi possível criar o arquivo " "O diretório pode estar protegido contra gravação, ou não há espaço livre."
					Else
						LjGrvLog( "Carga","Monta tabela temporaria, para recuperar quantidade de registros processados anteriormente")
						//Monta tabela temporaria, para recuperar quantidade de registros processados anteriormente						
						oTempTable := LJCInitialLoadTempTableExport():New(oCompleteTable, oCompleteTable:aBranches[nCount], Self:cExportType, "TABTMP")
						oTempTable:CreateTempTable()                            
						oTempTable:SetQtyRecords()
						nTotalRecords := oTempTable:nQtyRecords	  
						TABTMP->( dbCloseArea() )

						Self:UpdateQtyRecExport(oCompleteTable, oCompleteTable:aBranches[nCount], nTotalRecords )

						oResult:nRecords := nTotalRecords							
						aAdd( aResults, oResult )
					EndIf
				EndIf
			EndIf
			If (oCompleteTable:cTable $ Self:cTabRastro)
				LjGrvLog( "Rastro_Carga","Quantidade de registros da tabela temporaria: " + cValToChar((Self:aExpTemp[Len(Self:aExpTemp)][1])->(RecCount())) + " ( " + Self:aExpTemp[Len(Self:aExpTemp)][3] + " ) da filial " + oCompleteTable:aBranches[nCount])
			EndIf
		Next

		(oCompleteTable:cTable)->( DbCloseArea() )

	Else
		// "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
		oLJMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0015 + cTablePrefix + "_MSEXP" + STR0016 + cTablePrefix + "_HREXP " + STR0017 ) )
	EndIf
Else
	oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotOpenTable", 1, STR0005 + " '" + oCompleteTable:cTable + "'. " + STR0006) ) // "Não foi possível abrir a tabela" "Ela pode estar aberta de modo exclusivo por outro programa."
EndIf

LjGrvLog( "Carga","ExportComplete Fim")

Return aResults


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ExportPartial()

Exporta a tabela do tipo parcial

@param oPartialTable Objeto do tipo LJCInitialLoadPartialTable

@return aResults Array de objetos do tipo LJCInitialLoadMakerTransferFile
com os arquivos criados na geração da carga.
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method ExportPartial( oPartialTable ) Class LJCInitialLoadMaker
	Local aResults			:= {}
	Local oResult			:= Nil
	Local cFileNamePath		:= "" 
	Local cBranchField 		:= ""		
	Local aStruct			:= {}
	Local nCount			:= 0
	Local nCount2			:= 0
	Local lRenewTimer		:= .T.
	Local nTotalRecords		:= 0
	Local nSecond1			:= 0
	Local nSecond2			:= 0
	Local nRecordsProcessed	:= 0
	Local nRecord			:= 0
	Local oLJMessageManager	:= GetLJCMessageManager()
	Local cIndexKey			:= ""
	Local cTablePrefix		:= ""
	Local aRecords 			:= aClone( oPartialTable:aRecords )
	Local cFilter 			:= AllTrim(oPartialTable:cFilter)
	Local lOnlyFilter 	 	:= Len(aRecords) == 0 .And. !Empty(cFilter)
	Local aCampos 			:= {}
	Local oFrm				:= NIL
	Local cGerCSV			:= SuperGetMV("MV_LJGECSV",.F.,"0") //geracao de CSV 0 - Não gera, 1 - gera dbf/csv, 2 - somente csv	
	Local lGeraCSV			:= (cGerCSV == "1" .OR.  cGerCSV == "2") //Gera o arquivo CSV
	Local cFileNameCSV		:= "" //Nome do Arquivo CSV
	Local aStruct2			:= {} //Estrutura do arquivo
	Local lFileExists		:= .F.
	Local cRelease			:= GetRPORelease()	//Release atual
	Local lLJ1146GrvC		:= ExistBlock( "LJ1146GrvC") //Ponto de Entrada para gravação de campos  

	LjGrvLog( "Carga","ExportPartial Inicio")
	LjGrvLog( "Carga","P.E lLJ1146GrvC 	",lLJ1146GrvC	)

	If MpDicInDb() .AND. cRelease >= "12.1.025"
		lGeraCSV 	:= .T.
		cGerCSV		:= "2"
		LjGrvLog( "Carga","Release Atua: " + cRelease + " e Dicionario no banco, parametro MV_LJGECSV obrigatoriamente devera ser igual a '2'")								
	EndIf
	
	Self:oProgress:nStatus := 2
	  
	If ChkFile( oPartialTable:cTable, .F. )	
		// Abre a tabela de origem
		DbSelectArea( oPartialTable:cTable )
		
		// Pega a estrutura do banco de dados
	   	aStruct := (oPartialTable:cTable)->(DBStruct())

		oResult		:= LJCInitialLoadMakerTransferFile():New( oPartialTable:cTable, cEmpAnt, "" )
		cFileNamePath	:= Self:cRootPath + oResult:GetFileWithoutExtension() + IIf( ExistFunc("LJILRealExt") , LJILRealExt() , GetDBExtension() )		   	   
		cTablePrefix := If(SubStr(oPartialTable:cTable,1,1) == "S", SubStr(oPartialTable:cTable,2,3), oPartialTable:cTable)                            
		cBranchField :=  cTablePrefix + "_FILIAL"
		cFileNameCSV	:= Self:cRootPath + oResult:GetFileWithoutExtension() + ".csv"   	   
		
		LjGrvLog( "Carga","Arquivo " + cFileNamePath)
		
		 //protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
		 //nao valida se for a SX5 ou a SX6
		If (oPartialTable:cTable $ "SX5,SX6")  .OR. ( (oPartialTable:cTable)->(FieldPos(cTablePrefix + "_MSEXP")) > 0  .AND. (oPartialTable:cTable)->(FieldPos(cTablePrefix + "_HREXP")) > 0 )

			lFileExists := File(Left(cFileNamePath, Len(cFileNamePath)-3) + IIF(Self:nExtFile == 0, "mzp", "zip"))
							
			// Cria o arquivo temporário
			If cGerCSV <> "2"
				If !lFileExists					 
					DbCreate( cFileNamePath, aStruct, LJILRealDriver() )
				EndIf	
			EndIf
			
			If lGeraCSV
				oFrm := Self:GeraStrCSV(lGeraCSV, aStruct, cFileNameCSV, @aStruct2)
			EndIf	

			
			If ( cGerCSV <> "2" .AND.  File( cFileNamePath )) .OR. lGeraCSV
				// Abre a area com o arquivo novo
				If cGerCSV <> "2"					
					DbUseArea(.T.,  LJILRealDriver() , cFileNamePath, "TRB", .F., .F.)				
				EndIf
				
				If ( cGerCSV <> "2" .AND. Used()) .OR. lGeraCSV			
					nTotalRecords := (oPartialTable:cTable)->(RecCount())
					Self:oProgress:nTotalRecords := nTotalRecords			
					
					//Filtra os registros da tabela, caso nao tenha definido nenhum indice da tabela, mas tenha definido expressao de filtro
					If lOnlyFilter
						DbSelectArea( oPartialTable:cTable )
						(oPartialTable:cTable)->( dbSetFilter( {|| &(cFilter) } , cFilter ) )
						(oPartialTable:cTable)->(dbGoTop())
						aAdd( aRecords, { 1, "" } )
					EndIf
					
					For nCount := 1 To Len( aRecords )
						// Transporta o banco de dados para o arquivo local
						(oPartialTable:cTable)->( DbSetOrder( aRecords[nCount][1] ) )
						
						If (oPartialTable:cTable)->( DbSeek((xFilial(oPartialTable:cTable))+Rtrim(aRecords[nCount][2]) ) )

							cIndexKey := (oPartialTable:cTable)->(IndexKey(aRecords[nCount][1]))
							
							If Empty( cIndexKey )
								Loop
							EndIf     
							
							If cGerCSV <> "2" 
								For nCount2 := 1 To Len(aStruct)	
									aAdd(aCampos,{aStruct[nCount2][1],TRB->(FieldPos(aStruct[nCount2][1])) ,(oPartialTable:cTable) ,(oPartialTable:cTable)->(FieldPos( aStruct[nCount2][1]))})
								Next nCount2
							EndIf

							//se for SX5 permite o filtro de uma parte apenas do indice (para filtrar todos os registros da SX5 da tabela 23							
							While ( ((oPartialTable:cTable)->(&cIndexKey) == Left(aRecords[nCount][2],Len((oPartialTable:cTable)->(&cIndexKey)))) ;
							.OR. ( (oPartialTable:cTable == "SX5")  .AND. ( Left((oPartialTable:cTable)->(&cIndexKey),Len((xFilial(oPartialTable:cTable))+Rtrim(aRecords[nCount][2]) )) == Rtrim(xFilial("SX5")+aRecords[nCount][2]))) ;
							.OR. ( lOnlyFilter ) ) .And. !(oPartialTable:cTable)->(Eof())

								//nao avalia o MSEXP se for SX5 ou SX6
								If !(oPartialTable:cTable $ "SX5,SX6")
									If  Self:cExportType == INCREMENTAL .AND. !Empty((oPartialTable:cTable)->&(cTablePrefix +"_MSEXP"))
										(oPartialTable:cTable)->(DbSkip())
										loop 
									EndIf
								EndIf
										
										
								If !Empty(cFilter) .And. !(oPartialTable:cTable)->&(cFilter)
									(oPartialTable:cTable)->(DbSkip())
									TRB->(DbSkip())
									Loop
								EndIf				
			
								nRecord++
								
								If lRenewTimer
									nSecond1			:= Seconds()
									nRecordsProcessed	:= 0
									lRenewTimer 		:= .F.
								EndIf	
								
										
								If cGerCSV <> "2" 
									RecLock( "TRB", .T. )
									For nCount2 := 1 To Len(aStruct)	
										If aStruct[nCount2][1] == cTablePrefix + "_MSEXP"
											TRB->&(aCampos[nCount2][1]) := DtoS(dDataBase) 					
										ElseIf aStruct[nCount2][1] == cTablePrefix + "_HREXP"
											TRB->&(aCampos[nCount2][1]) := Left(Time(),8) 				
										Else
											TRB->&(aCampos[nCount2][1]) := (oPartialTable:cTable)->&(aCampos[nCount2][1])
	
										EndIf
									Next nCount2
									TRB->(MsUnLock())
								EndIf
					
								Self:GeraDadoCSV(lGeraCSV, aStruct2, cTablePrefix, oPartialTable:cTable, @oFrm) 
				
								nSecond2 := Seconds()
				
								If nSecond2 - nSecond1 >= 1
									lRenewTimer := .T.
									// Avisa a todos os interessando o progresso da geração da carga inicial			
									Self:oProgress:nActualRecord := nRecord
									Self:oProgress:nRecordsPerSecond := Int( nRecordsProcessed / (nSecond2-nSecond1) )
									Self:Notify()
								EndIf
						
								(oPartialTable:cTable)->(DbSkip())
								nRecordsProcessed++				
							End
							
							//Atualiza a quantidade de registros exportados na MBV
							Self:UpdateQtyRecExport(oPartialTable,nil , nRecord)
							
							
						EndIf
					Next
					
					Self:CloseArqCSV(lGeraCSV, @oFrm)
					
					//Limpa todas as condicoes de filtro
					If lOnlyFilter
						DbSelectArea( oPartialTable:cTable )
						(oPartialTable:cTable)->( dbClearFilter() )
					EndIf
					
					// Avisa a todos os interessando o progresso da geração da carga inicial			
					Self:oProgress:nActualRecord := nTotalRecords
					Self:oProgress:nRecordsPerSecond := Int( nRecordsProcessed / (nSecond2-nSecond1) )
					Self:Notify()				
	
					If cGerCSV <> "2" 
						TRB->(DbCloseArea())
					EndIf
		
					If !oLJMessageManager:HasError()
						oResult:nRecords := nRecord
						aAdd( aResults, oResult )
					EndIf				
				Else
					oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotOpenCreatedTable", 1, STR0010 + " '" + cFileNamePath + "'. " + STR0011) ) // "O arquivo de dados foi criado, mas não foi possível sua abertura " "O driver utilizado pode estar errado."
				EndIf
			Else
				If !lFileExists
					oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotCreateTable", 1, STR0012 + " '" + cFileNamePath + "'. " + STR0013) ) // "Não foi possível criar o arquivo " "O diretório pode estar protegido contra gravação, ou não há espaço livre."
				Else
				    //Adiciona oResult para que carga prossiga a partir do ponto de interrupcao da execução anterior
					oResult:nRecords := (oPartialTable:cTable)->(RecCount())
					aAdd( aResults, oResult )
				EndIf
			EndIf
		Else	//protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
			oLJMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0015 + cTablePrefix + "_MSEXP" + STR0016 + cTablePrefix + "_HREXP " + STR0017 ) ) //  "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cTablePrefix + "_MSEXP" + " e " + cTablePrefix + "_HREXP existem."
		EndIf
		(oPartialTable:cTable)->(DbCloseArea())								
	Else
		oLJMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadMakerConnotOpenTable", 1, STR0005 + " '" + oPartialTable:cTable + "'. " + STR0006) ) // "Não foi possível abrir a tabela" "Ela pode estar aberta de modo exclusivo por outro programa."
	EndIf	
	
	LjGrvLog( "Carga","ExportPartial Inicio")
	
Return aResults



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ExportSpecial()

Exporta a tabela do tipo special

@param oSpecialTable Objeto do tipo LJCInitialLoadSpecialTable

@return aResults: Array de objetos do tipo LJCInitialLoadMakerTransferFile
com os arquivos criados na geração da carga.
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method ExportSpecial( oSpecialTable ) Class LJCInitialLoadMaker
	Local oFactory			:= LJCInitialLoadSpecialTableFactory():New()
	Local oLJMessageManager	:= GetLJCMessageManager()	
	Local oExporter 		:= Nil
	Local aResults			:= {}
	Local cNoFields			:= "" //Campos que nao existem na base
		
	oExporter := oFactory:GetExporterByName( oSpecialTable:cTable )
		 
	
	DbSelectArea("SB1")
	DbSelectArea("SB0")
	
	//protecao - valida se os campos MSEXP e HREXP existem nas tabelas que receberao a carga
	If !( SB1->(FieldPos("B1_MSEXP")) > 0 )
		cNoFields := " B1_MSEXP,"
	EndIf
	If !( SB1->(FieldPos("B1_HREXP")) > 0 )
		cNoFields += " B1_HREXP,"
	EndIf
	
	If !( SB0->(FieldPos("B0_MSEXP")) > 0 )
		cNoFields += " B0_MSEXP,"
	EndIf
	
	If !( SB0->(FieldPos("B0_HREXP")) > 0 )
		cNoFields += " B0_HREXP,"
	EndIf
	
	If SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ
		//Verifica se existem os campo MSEXP e HREXP na tabela SBZ
		DbSelectArea("SBZ")
		If !( SBZ->(FieldPos("BZ_MSEXP")) > 0 )
			cNoFields += " BZ_MSEXP,"
		EndIf
		If !( SBZ->(FieldPos("BZ_HREXP")) > 0 )
			cNoFields += " BZ_HREXP,"
		EndIf
	EndIf
	
	If Empty(cNoFields)
		If !oLJMessageManager:HasError()
			aResults := oExporter:Execute( oSpecialTable, Self )
		EndIf
	Else
		cNoFields := Left(cNoFields,Len(cNoFields)-1) //Tira a ultima virgula
		oLJMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadLoaderFieldDoesntExist", 1, STR0015 + cNoFields + STR0017 ) ) //   "Campos necessários para a Carga Incremental não existem. Verifique se os campos " + cNoFields + " existem."
	EndIf
	
		
Return aResults


//--------------------------------------------------------------------------------
/*/{Protheus.doc} AddObserver()

Adiciona um objeto que observa essa classe

@param oObserver Objeto que observa esta classe. 

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method AddObserver( oObserver ) Class LJCInitialLoadMaker
	aAdd( Self:aoObservers, oObserver )
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} Notify()

Notifica as classes que observam esta da atualização do progresso

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------------------    
Method Notify() Class LJCInitialLoadMaker
	Local nCount := 0
	
	For nCount := 1 To Len( Self:aoObservers )
		Self:aoObservers[nCount]:Update( Self:oProgress )
	Next
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} SetExportType()

Define se a carga eh inteira ou incremental (MSEXP)

@param cExportType Tipo da carga.

@return Nenhum

@author Vendas CRM
@since 26/06/12
/*/
//--------------------------------------------------------------------------------    
Method SetExportType( cExportType ) Class LJCInitialLoadMaker
	Self:cExportType := cExportType
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} SetCodInitialLoad()

Define o codigo da carga na tabela MBU 

@param cCodInitialLoad: codigo da carga

@return Nenhum

@author Vendas CRM
@since 29/06/12
/*/
//--------------------------------------------------------------------------------    
Method SetCodInitialLoad( cCodInitialLoad ) Class LJCInitialLoadMaker
	Self:cCodInitialLoad := cCodInitialLoad
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} UpdateQtyRecExport()

Grava no banco a quantidade de registros exportados no arquivo da carga

@param oTable Tabela
@param cBranche Filial
@param nQty Quantidade de registros exportados no arquivo da carga

@return Nil

@author Vendas CRM
@since 29/06/12
/*/
//--------------------------------------------------------------------------------    
Method UpdateQtyRecExport(oTable, cBranche, nQty) Class LJCInitialLoadMaker


//Se for exportacao do tipo parcial (nao gera MBX) grava a quantidade exportada na MBV
If Lower(GetClassName( oTable )) == Lower("LJCInitialLoadPartialTable")
	
	DbSelectArea("MBV")
	DbSetOrder(1) // Filial + grupo de carga + tabela 
	
	If DbSeek(xFilial("MBV") + Self:cCodInitialLoad + oTable:cTable )
		RecLock( "MBV", .F. )
		Replace MBV->MBV_QTDREG With nQty
		MBV->(MsUnLock())
	EndIf	

Else //Se for exportacao do tipo completa ou especial grava a quantidade exportada na MBX (a qtde depende da filial)

	DbSelectArea("MBX")
	DbSetOrder(1) // Filial + grupo de carga + tabela + filial da carga
	
	If DbSeek(xFilial("MBX") + Self:cCodInitialLoad + oTable:cTable + cBranche)
		RecLock( "MBX", .F. )
		Replace MBX->MBX_QTDREG With nQty
		MBX->(MsUnLock())
	EndIf	

EndIf
	
Return Nil


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveLoadRecord()

Remove uma carga (apaga registros no banco das tabelas da carga)

@param cCodInitialLoad código da carga na MBU
 
@return Nil

@author Vendas CRM
@since 29/06/12
/*/
//--------------------------------------------------------------------------------    
Method RemoveLoadRecord(cCodInitialLoad) Class LJCInitialLoadMaker

Default cCodInitialLoad := ""

LjGrvLog( "Carga","Remove carga " + cCodInitialLoad )

DbSelectArea( "MBU" )
DbSetOrder( 1 )
MBU->( DbSeek( xFilial( "MBU" ) + cCodInitialLoad) )
While	MBU->MBU_FILIAL + MBU->MBU_CODIGO == xFilial( "MBU" ) + cCodInitialLoad .And. MBU->( !EOF() )
	RecLock( "MBU", .F. )
	MBU->( DbDelete() )
	MBU->( MsUnLock() )
	MBU->( DbSkip() )
EndDo


DbSelectArea( "MBV" )
DbSetOrder( 1 )
MBV->( DbSeek( xFilial( "MBV" ) + cCodInitialLoad) )
While	MBV->MBV_FILIAL + MBV->MBV_CODGRP == xFilial( "MBV" ) + cCodInitialLoad .And. MBV->( !EOF() )
	RecLock( "MBV", .F. )
	MBV->( DbDelete() )
	MBV->( MsUnLock() )
	MBV->( DbSkip() )
EndDo


DbSelectArea( "MBW" )
DbSetOrder( 1 )
MBW->( DbSeek( xFilial( "MBW" ) + cCodInitialLoad) )
While	MBW->MBW_FILIAL + MBW->MBW_CODGRP == xFilial( "MBW" ) + cCodInitialLoad .And. MBW->( !EOF() )
	RecLock( "MBW", .F. )
	MBW->( DbDelete() )
	MBW->( MsUnLock() )
	MBW->( DbSkip() )
EndDo


DbSelectArea( "MBX" )
DbSetOrder( 1 )
MBX->( DbSeek( xFilial( "MBX" ) + cCodInitialLoad) )
While	MBX->MBX_FILIAL + MBX->MBX_CODGRP == xFilial( "MBX" ) + cCodInitialLoad .And. MBX->( !EOF() )
	RecLock( "MBX", .F. )
	MBX->( DbDelete() )
	MBX->( MsUnLock() )
	MBX->( DbSkip() )
EndDo

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} GeraStrCSV

Cria o arquivo CSV

@param lGeraCSV Gera arquivo CSV
@param aStruct Estrutura do arquivo
@param cFileNameCSV - Nome do arquivo
@param aStruct2 - Estrutura 2 do arquivo
 
@return oFrm - Informações do Arquivo onde
[1] - handle do arquivo
[2] - header do arquivo
[3] - Numero de Linhas contando com o cabeçalho
[4] - Nome do arquivo

@author Vendas CRM
@since 03/02/2015
/*/
//--------------------------------------------------------------------------------    
Method GeraStrCSV(lGeraCSV, aStruct, cFileNameCSV, aStruct2) Class LJCInitialLoadMaker
Local nC 		:= 0 //Contador
Local nTotStru 	:= 0 //Estrutura do arquivo
Local oFrm 		:= {} //dados do arquivo CSV
Local aHeader 	:= {} //header
Local nHandle 	:= 0 //handle
Local cLinha	:= "" //Linha

LjGrvLog( "Carga","Gera CSV ")

If lGeraCSV

  	nTotStru := Len(aStruct)
   	For nC := 1 to nTotStru
		aADD(aHeader, aStruct[nC, 1])
		aAdd(aStruct2, aClone(aStruct[nC]))
 	Next
   		
	If File(cFileNameCSV)
		FErase(cFileNameCSV)
	EndIf

	nHandle := FCreate(cFileNameCSV)
	oFrm := {nHandle,aHeader, 0, cFileNameCSV} 
	
	If nHandle <> -1
		
		For nC := 1 to Len(aHeader)
			cLinha := cLinha + aHeader[nC]+";"
		Next
	
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF
		fWrite(oFrm[1], cLinha)	
		oFrm[3] := oFrm[3] + 1	

	EndIf
EndIf
	   	
Return oFrm


//--------------------------------------------------------------------------------
/*/{Protheus.doc} GeraDadoCSV

Grava a linha do aquivo CSV

@param lGeraCSV Gera arquivo CSV
@param aStruct2 - Estrutura 2 do arquivo
@param cTablePrefix - Prefixo do arquivo
@param cAliasTemp - Alias temporário
@param oFrm - Estrutura do arquivo CSV
 
@return nil

@author Vendas CRM
@since 03/02/2015
/*/
//--------------------------------------------------------------------------------    
Method GeraDadoCSV(lGeraCSV, aStruct2, cTablePrefix, cAliasTemp, oFrm) Class LJCInitialLoadMaker
Local aTMP 			:= {} //Array temporário
Local nCount2 		:= 0	//Contador
Local cDado 		:= ""//Dado
Local cLinha 		:= "" //Linha
Local nColunas 		:= 0 //Coluna
Local aFieldsX		:= {}// Array com retorno de campos customizados com respcetivos valores
Local lLJ1146GrvC	:= ExistBlock( "LJ1146GrvC") //Ponto de Entrada para gravação de campos
Local lFieldsX		:= .F. // Se existe PE  LJ1146GrvC e retornou campos para gravar no CSV
Local nCont			:= 0
Local cFieldsX		:= ""

If lGeraCSV

	aTMP := {}
	 
	If lLJ1146GrvC
		aFieldsX:= ExecBlock( "LJ1146GrvC", .F., .F., { aStruct2, cTablePrefix } )
		lFieldsX := lLJ1146GrvC .AND. Len(aFieldsX) > 0 
		For nCont := 1 To Len(aFieldsX) 
			 cFieldsX += "|" + aFieldsX[nCont][1]
		Next nCont   	
	Endif
	
	

	For nCount2 := 1 To Len(aStruct2)
		
		If aStruct2[nCount2][1] == cTablePrefix + "_MSEXP"
			cDado :=  DtoS(dDataBase)					
		ElseIf aStruct2[nCount2][1] == cTablePrefix + "_HREXP"
			cDado :=  Left(Time(),8)
		Elseif lFieldsX .AND. aStruct2[nCount2][1]$cFieldsX	
			cDado := 	aFieldsX[aScan(aFieldsX, {|x| AllTrim(x[1]) == aStruct2[nCount2][1]})][2]	
		ElseIf aStruct2[nCount2][1] == "REC"
			cDado := cValToChar((cAliasTemp)->(FieldGet(ColumnPos( aStruct2[nCount2][1]) )))
		Else
			cDado := (cAliasTemp)->(FieldGet(ColumnPos( aStruct2[nCount2][1]) ))
		EndIf
		
		cDado := LjCSVConvtype(cDado, aStruct2[nCount2][2], aStruct2[nCount2][3], .F., aStruct2[nCount2][4])
		cLinha := cLinha + cDado + ";"
		nColunas++

	Next nCount2	
		
	If nColunas == Len(oFrm[2])
		
		cLinha := Substr(cLinha, 1, Len(cLinha)-1) + CRLF
		
		If oFrm[3] == 5000
			fClose(oFrm[1])

			//Se esta usando a configuração para compactar como ZIP, então
			//verifica se eh necessario quebrar o arquivo por conta da limitação da FZip
			If Self:nExtFile == 1
				If Self:TamArquivo(Self:CamRootPath() + oFrm[4])
					Self:nProxArq++
					oFrm := Self:NovoArquivo()
				EndIf
			EndIf

			oFrm[1] := FOpen(oFrm[4],2)
			FSeek(oFrm[1], 0, 2) //Posiciona no final do arquivo
			oFrm[3] := 0
		EndIf

		If oFrm[1] <> -1
			If (IIF(Len(cTablePrefix) == 2, "S" + cTablePrefix, cTablePrefix)  $ Self:cTabRastro)
				LjGrvLog( "Rastro_Carga","O arquivo " + oFrm[4] + " vai receber o registro: " + cLinha)
			EndIf
			FWrite(oFrm[1], cLinha, Len(cLinha))
			oFrm[3] := oFrm[3]+1
		Else
			If (Self:cTabela $ Self:cTabRastro)
				LjGrvLog( "Rastro_Carga","1 - O arquivo " + oFrm[4] + " não recebeu o registro: " + cLinha)
			EndIf
		EndIf
	Else
		If (Self:cTabela $ Self:cTabRastro)
			LjGrvLog( "Rastro_Carga","2 - O arquivo " + oFrm[4] + " não recebeu o registro: " + cLinha)
		EndIf
	EndIf
							
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} CloseArqCSV

Fecha o aquivo CSV

@param lGeraCSV Gera arquivo CSV
@param oFrm - Estrutura do arquivo CSV
 
@return nil

@author Vendas CRM
@since 03/02/2015
/*/
//--------------------------------------------------------------------------------    
Method CloseArqCSV(lGeraCSV, oFrm)  Class LJCInitialLoadMaker

If lGeraCSV
	If oFrm[1] <> -1
		FClose(oFrm[1])
	EndIf
EndIf

return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveWithoutRecord()

Remove uma carga, ou parte da carga (caso nao tenha registro gerado para a carga para a tabela em questao) 
(apaga registros das tabelas da carga e exclui o diretorio, caso nenhuma tabela tenha registro gerado na carga). 


@param cCodInitialLoad código da carga na MBU
 
@return Nil

@author Varejo
@since 01/04/2015
/*/
//--------------------------------------------------------------------------------    
Method RemoveWithoutRecord(cCodInitialLoad,aLoadTables,aLoadDel,lExitCarga) Class LJCInitialLoadMaker
Local cTable 		:= ""
Local nX 			:= 0
Local nY 			:= 0
Local aDir	 		:= {}
Local oLJCMessageManager := GetLJCMessageManager() 

For nX:=1 To Len(aLoadDel)
	cTable := aLoadDel[nX][1]
	// -----------------------
	// Deleta registro da MBX
	// -----------------------
	DbSelectArea( "MBX" )
	MBX->( DbSetOrder( 1 ) ) //MBX_FILIAL+MBX_CODGRP+MBX_TABELA+MBX_FIL
	For nY:=1 To Len(aLoadDel[nX][2])
		If MBX->( DbSeek( xFilial( "MBX" ) + cCodInitialLoad + cTable + aLoadDel[nX][2][nY] ) )
			RecLock( "MBX", .F. )
			MBX->( DbDelete() )
			MBX->( MsUnLock() )
		EndIf
	Next nY
	
	// ---------------------------------------------------------------------
	// Deleta registro da MBV, caso nao tenha registro correspondente na MBX 
	// ---------------------------------------------------------------------
	If !MBX->( DbSeek( xFilial( "MBX" ) + cCodInitialLoad + cTable ) )
		DbSelectArea( "MBV" )
		MBV->( DbSetOrder( 1 ) ) //MBV_FILIAL+MBV_CODGRP+MBV_TABELA
		If MBV->( DbSeek( xFilial( "MBV" ) + cCodInitialLoad + cTable ) )
			RecLock( "MBV", .F. )
			MBV->( DbDelete() )
			MBV->( MsUnLock() )
		EndIf
	EndIf
	
	// ---------------------------------------------------------------------
	// Deleta registro da MBW, caso nao tenha registro correspondente na MBX 
	// ---------------------------------------------------------------------
	If !MBX->( DbSeek( xFilial( "MBX" ) + cCodInitialLoad + cTable ) )
		DbSelectArea( "MBW" )
		MBW->( DbSetOrder( 1 ) ) //MBW_FILIAL+MBW_CODGRP+MBW_TABELA
		If MBW->( DbSeek( xFilial( "MBW" ) + cCodInitialLoad + cTable ) )
			RecLock( "MBW", .F. )
			MBW->( DbDelete() )
			MBW->( MsUnLock() )
		EndIf
	EndIf
	
Next nX

//Se nao existir nenhuma carga gerada para o processo, entao exclui registro da "MBU"
If !lExitCarga
	DbSelectArea( "MBU" )
	DbSetOrder( 1 )
	If MBU->( DbSeek( xFilial( "MBU" ) + cCodInitialLoad) )
		RecLock( "MBU", .F. )
		MBU->( DbDelete() )
		MBU->( MsUnLock() )
	EndIf
	
	Self:ClearPath( .T. )
Else
	//Faz a limpeza no diretorio do processo de carga em questao, pra excluir os arquivos gerados sem conteudo
	aDir := Directory( Self:cRootPath + "*.*" )
	For nX := 1 To Len( aDir )
		
		If Upper(Right(aDir[nX][1],3)) <> IIF(Self:nExtFile == 0, "MZP", "ZIP") //Somente exclui arquivos que não sejam extensao ".MZP" ou ".ZIP"		
			If FErase( Self:cRootPath + aDir[nX][1] ) != 0
				oLJCMessageManager:ThrowMessage( LJCMessage():New("LJInitialLoadIOMessage", 1, STR0002 + " '" + Self:cRootPath + aDir[nX][1] + "'." ) ) // "Não foi possível apagar o arquivo temporário"
				lDelDir := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf 

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} GetQtyRecExport()

Retorna a quantidade de registros exportados no arquivo da carga
@type function
@param oTable Tabela
@param cBranche Filial
 
@return nQty Quantidade de registros exportados no arquivo da carga

@author Varejo
@since 09/05/2016
/*/
//--------------------------------------------------------------------------------    
Method GetQtyRecExport(oTable, cBranche) Class LJCInitialLoadMaker
Local nQty := 0 //Quantidade de registros

Default oTable 	:= Nil		//Tabela
Default cBranche	:= ""		//Filial da Carga

//Se for exportacao do tipo parcial (nao gera MBX) grava a quantidade exportada na MBV
If Lower(GetClassName( oTable )) == Lower("LJCInitialLoadPartialTable")
	
	DbSelectArea("MBV")
	DbSetOrder(1) // Filial + grupo de carga + tabela 
	
	If DbSeek(xFilial("MBV") + Self:cCodInitialLoad + oTable:cTable )
		nQty := MBV->MBV_QTDREG 
	EndIf	

Else //Se for exportacao do tipo completa ou especial grava a quantidade exportada na MBX (a qtde depende da filial)

	DbSelectArea("MBX")
	DbSetOrder(1) // Filial + grupo de carga + tabela + filial da carga
	
	If DbSeek(xFilial("MBX") + Self:cCodInitialLoad + oTable:cTable + cBranche)
		nQty := MBX->MBX_QTDREG 		
	EndIf	

EndIf
LjGrvLog( "Carga","quantidade de registros exportados " ,nQty )
	
Return nQty

//-----------------------------------------------------------------
/*/{Protheus.doc} AtlzMsExp()

Atualiza os campos de MSEXP e HREXP
 
@return Nil
@author Varejo
@since  05/07/2022
/*/
//-----------------------------------------------------------------
Method AtlzMsExp() Class LJCInitialLoadMaker

Local cMsExp 	:= ""
Local cHrExp 	:= ""
Local cData		:= SubStr(FwTimeStamp(1),1,8)
Local cHora		:= Time()
Local nI		:= 0
Local cTemp		:= ""
Local oTemp		:= Nil
Local cTabe		:= ""
Local cRecIgnora:= Self:oTabExc:GetAlias()

/*
	Todos os registro que estão dentro da tabela temporia da variavel cRecIgnora não serão atualizados os campos MSEXP e HREXP.
	Serão ignorados porque esses registros não entraram dentro do arquivo .csv da carga, e devido a isso o MSEXP devera ficar em branco 
	para uma próxima carga. 
*/
dbSelectArea(cRecIgnora)

For nI := 1 To Len(Self:aExpTemp)

	cTemp 	:= Self:aExpTemp[nI][1]
	oTemp 	:= Self:aExpTemp[nI][2]
	cTabe	:= Self:aExpTemp[nI][3]
	cMsExp 	:= IIf( SubStr(Self:aExpTemp[nI][3],1,1) == "S", SubStr(Self:aExpTemp[nI][3],2,2), Self:aExpTemp[nI][3] ) + "_MSEXP"
	cHrExp 	:= IIf( SubStr(Self:aExpTemp[nI][3],1,1) == "S", SubStr(Self:aExpTemp[nI][3],2,2), Self:aExpTemp[nI][3] ) + "_HREXP"

	Self:ValidaCsv(nI)
	
	If (cTabe $ Self:cTabRastro)
		LjGrvLog( "Rastro_Carga","Quantidade de registros que serão ignorados na atualização do MSEXP e HREXP: " + cValToChar((cTemp)->(RecCount()) - (cRecIgnora)->(RecCount())))
	EndIf
	
	(cTemp)->( DbGoTop() )

	While (cTemp)->(!EoF())
		
		(cRecIgnora)->(dbSetOrder(1))

		If (cRecIgnora)->(dbSeek(cTabe + (cTemp)->REC))

			(cTabe)->(dbGoTo(Val((cTemp)->REC)))
			RecLock(cTabe,.F.)
			(cTabe)->&(cMsExp) := cData
			(cTabe)->&(cHrExp) := cHora
			(cTabe)->(MsUnLock())
			If (cTabe $ Self:cTabRastro)
				LjGrvLog( "Rastro_Carga","Atualizou o MSEXP e HREXP do registro RECNO = " + cValToChar((cTemp)->REC) + " da tabela " + cTabe + " no arquivo .csv do pacote " + Self:cCodInitialLoad)
			EndIf
			
		EndIf

		(cTemp)->( DbSkip() )

	End 

	Self:oTabExc:Zap()

	oTemp:Delete()
	FwFreeObj(oTemp)
	oTemp := Nil

Next nI

DirRemove(Self:cRootPath + "backup")

Self:oTabExc:Delete()
FwFreeObj(Self:oTabExc)
Self:oTabExc := Nil

Self:aExpTemp := {}

Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} SizeFile()

Metodo responsavel e verificar o tamanho do arquivo CSV e retornar
se cria um novo arquivo para dividir os dados ou nao
 
@return .T. para criar novo arquivo / .F. para não criar novo arquivo
@author Bruno Almeida
@since  16/09/2022
/*/
//-----------------------------------------------------------------
Method TamArquivo(cArquivo) Class LJCInitialLoadMaker

Local oArquivo	:= Nil
Local lRet		:= .F.

If !Empty(cArquivo)
	oArquivo := FWFileReader():New(cArquivo)
	If oArquivo:Open() .AND. oArquivo:getFileSize() >= 2000000000
		lRet := .T.
	EndIf
	oArquivo:Close()
	FwFreeObj(oArquivo)
	oArquivo := Nil
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} CamRootPath()

Retorna apenas o caminho do RooPath
 
@return Retorno do caminho do RooPath configurado no ini da aplicacao
@author Bruno Almeida
@since  16/09/2022
/*/
//-----------------------------------------------------------------
Method CamRootPath() Class LJCInitialLoadMaker

Local cRet := GetSrvProfString ("RootPath","")

If SubStr(cRet, Len(cRet), 1) == "\"
	cRet := SubStr(cRet, 1, Len(cRet) - 1)
EndIf

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} NovoArquivo()

Após atingir o limite do arquivo, então é criado um novo arquivo CSV
 
@return Nil
@author Bruno Almeida
@since  19/09/2022
/*/
//-----------------------------------------------------------------
Method NovoArquivo() Class LJCInitialLoadMaker

Local oResult 		:= LJCInitialLoadMakerTransferFile():New( Self:cTabela, Self:cEmpresa, Self:cFilialArq )
Local cFileNameCSV 	:= Self:cRootPath + oResult:GetFileWithoutExtension() + "_" + AllTrim(Str(Self:nProxArq)) + ".csv"
Local oRet			:= Nil

oRet := Self:GeraStrCSV(.T., Self:aEstrutura, cFileNameCSV, {})

fClose(oRet[1])

FwFreeObj(oResult)
oResult := Nil

Return oRet


//-----------------------------------------------------------------
/*/{Protheus.doc} TabMsExp()

Metodo responsavel para incluir os registros na tabela temporaria que sera
utilizada para atualizar os campos de MSEXP e HREXP.
 
@return Nil
@author Bruno Almeida
@since  25/03/2024
/*/
//-----------------------------------------------------------------
Method TabMsExp() Class LJCInitialLoadMaker

Local cTemp		:= Self:aExpTemp[Len(Self:aExpTemp)][1]
Local aStruct 	:= (cTemp)->(dbStruct())
Local nI		:= 0

TABTMP->( DbGoTop() )

While TABTMP->(!EoF())
	RecLock(cTemp,.T.)
	For nI := 1 To Len(aStruct)
		If aStruct[nI][1] == "REC"
			(cTemp)->&(aStruct[nI][1]) := cValToChar(TABTMP->&(aStruct[nI][1]))
		Else
			(cTemp)->&(aStruct[nI][1]) := TABTMP->&(aStruct[nI][1])
		EndIf
	Next nI
	(cTemp)->(MsUnLock())
	TABTMP->( DbSkip() )
End 

Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} ValidaCsv

Neste metodo estamos fazendo uma blindagem para saber se tudo que tem no arquivo
.csv realmente tem na tabela temporaria. Caso algum registro que tem na tabela
temporaria não esteja no arquivo .csv, esse registro não tera o campo _MSEXP
preenchido e deverar entrar para o pacote em uma próxima carga.
 
@return Nil
@author Bruno Almeida
@since  18/04/2024
/*/
//-----------------------------------------------------------------
Method ValidaCsv(nPos) Class LJCInitialLoadMaker

Local cBarra 		:= IIF(IsSrvUnix(), "/", "\")
Local aFiles 		:= StrTokArr(Self:aExpTemp[nPos][4], ";")
Local nX			:= 0
Local aCsv			:= ""
Local cFileName		:= ""
Local nfHandle		:= 0
Local nFileSize 	:= 0
Local nBytesRead	:= 0
Local cBuffer		:= ""
Local nAtPlus 		:= ( Len( CRLF ) -1 )
Local nBufferSize 	:= 6500
Local nPosRec		:= 0
Local cTemp 		:= Self:oTabExc:GetAlias()

For nX := 1 To Len(aFiles)

	aCsv 		:= StrTokArr(aFiles[nX], cBarra)
	cFileName 	:= Self:cRootPath + "backup\" + aCsv[Len(aCsv)]

	If File(cFileName)
		nfHandle := FOpen(cFileName)
		If nfHandle <> -1
			
			nBytesRead 	:= 0
			nFileSize 	:= fSeek(nfHandle,0,2) //-- Pega o tamanho total do arquivo
			fSeek(nfHandle,0,0) //-- Volta para o inicio do arquivo

			While ( nBytesRead <= nFileSize ) 

				cBuffer 	+= fReadStr( @nfHandle , @nBufferSize ) 
				nBytesRead 	+= nBufferSize 

				While ( CRLF $ cBuffer ) 
					
					cLine 	:= SubStr( cBuffer , 1 , ( AT( CRLF , cBuffer ) + nAtPlus ) ) 
					cBuffer := SubStr( cBuffer , Len( cLine ) + 1 ) 
					cLine 	:= StrTran( cLine , CRLF , "" ) 
					nPosRec := RAt(";",cLine) + 1

					If AllTrim(SubStr(cLine, nPosRec, 3)) <> "REC"
						RecLock(cTemp, .T.)
						(cTemp)->TABELA := Self:aExpTemp[nPos][3]
						(cTemp)->RECNO 	:= AllTrim(SubStr(cLine, nPosRec))
						(cTemp)->( MsUnLock() )
					EndIf
			
				End				
			
			End

			fClose(nfHandle)
		Else
			If ( Self:aExpTemp[nPos][3] $ Self:cTabRastro )
				LjGrvLog( "Rastro_Carga","Não foi possivel fazer a abertura do arquivo " + cFileName + ". Não sera atualizado o _MSEXP dos registros que compõe esse pacote e ficara pendente para uma próxima carga.")
			EndIf
		EndIf
		FErase(cFileName)		
	EndIf

Next nX

Return Nil
