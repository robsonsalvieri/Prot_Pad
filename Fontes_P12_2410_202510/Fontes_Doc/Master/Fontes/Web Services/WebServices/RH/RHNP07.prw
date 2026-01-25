#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"

#INCLUDE "RHNP07.CH"

Function RHNP07()
Return .T.

WSRESTFUL File DESCRIPTION STR0013 //"Requisitos para anexar um arquivo no Meu RH"

	//****************************** GETs ***********************************
	WSMETHOD GET fileRequire ;
	DESCRIPTION STR0014 ; //"Serviço que retorna os tipos de arquivo válidos"
	WSSYNTAX "/file/attachmentRequirements" ;
	PATH "/file/attachmentRequirements" PRODUCES 'application/json;charset=utf-8'

END WSRESTFUL

WSMETHOD GET fileRequire WSREST File

	Local oItem			:= Nil
	Local oExtensions	:= Nil
	Local aExtensions	:= {}


	//Gera os elementos do JSON
	oItem					:= JsonObject():New()
	oItem["extension"]		:= "jpeg"
	oItem["mimeType"]		:= "image/jpeg"
	aAdd(aExtensions, oItem)

	oItem					:= JsonObject():New()
	oItem["extension"]		:= "jpg"
	oItem["mimeType"]		:= "image/jpg"
	aAdd(aExtensions, oItem)

	oItem					:= JsonObject():New()
	oItem["extension"]		:= "png"
	oItem["mimeType"]		:= "image/png"
	aAdd(aExtensions, oItem)

	oItem					:= JsonObject():New()
	oItem["extension"]		:= "pdf"
	oItem["mimeType"]		:= "application/pdf"
	aAdd(aExtensions, oItem)

	oExtensions					:= JsonObject():New()
	oExtensions["extensions"]	:= aExtensions
	oExtensions["maxFileSize"]	:= 5000

	cJson := oExtensions:ToJson()
	Self:SetResponse(cJson)

Return(.T.)

/*/{Protheus.doc} getNextACB
Obtem o próximo numero de registro valido para a tabela ACB 
@author: Marcelo Silveira
@since:	18/07/2022
@return: cNum, proximo numero de registro da tabela ACB
/*/
Function getNextACB()

    Local aAreaAux  := {}
    Local cNum      := ""
    Local cQuery    := ""
    Local cAliasAux := ""
       
    aAreaAux := GetArea()
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³A numeração deve ser unica por empresa.                            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cQuery := "SELECT MAX(ACB_CODOBJ) SEQUEN "
    cQuery += "  FROM " + RetSqlName( "ACB" ) + " ACB "
	cQuery += " WHERE ACB_FILIAL = '" + xFilial("ACB", SRA->RA_FILIAL) + "'"
    cQuery += " AND D_E_L_E_T_ = ' '"
    cQuery := ChangeQuery( cQuery )
        
    cAliasAux := GetNextAlias()  
        
    dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasAux, .F., .T. )
        
    IF Select( cAliasAux ) > 0
            
        cNum := Soma1((cAliasAux)->SEQUEN)

        DbSelectArea(cAliasAux)
        DbCloseArea()
    Endif
            
    RestArea(aAreaAux)    	
	    
Return cNum

/*/{Protheus.doc} fGetPathBco
Obtem o Path do banco de conhecimento
@author: Marcelo Silveira
@since:	18/07/2022
@return: Nil
/*/
Function fGetPathBco(cCodEmp)

    Local cPath     := ""
    Local cDirDoc   := Alltrim(GetMv("MV_DIRDOC"))

	DEFAULT cCodEmp := cEmpAnt

    //Se o ultimo caracter nao for uma \, acrescenta ela, e depois configura o diretorio com a subpasta co01\shared
    If SubStr(cDirDoc, Len(cDirDoc), 1) != '\'
        cDirDoc := cDirDoc + "\"
    EndIf
    cPath := cDirDoc + 'co' + cCodEmp +'\shared\' //Diretorio padrao do banco de conhecimento

	fChkDirDoc(cPath) //Verifica a estrutura dos diretorios

Return( cPath )

/*/{Protheus.doc} fSetBcoFile()
- Responsável por gravar o anexo do atestado no Banco de Conhecimento
@author:	Marcelo Silveira
@since:		18/07/2022
@param:		cFileContent - Conteudo codificado do anexo
			cNameArq - Nome do arquivo para o Banco de Conhecimento
			cFileType - Extensao do arquivo
			cError - Erros durante a criacao do arquivo (referencia)
			cCodEmp - Codigo da empresa onde deve ser feita a consulta			
@return:	lRet - Imagem criada no servidor para geracao ou atualizacao no Banco de Conhecimento
/*/
Function fSetBcoFile( cFileContent, cNameArq, cFileType, cError, cCodEmp )

	Local nHandle
	Local oFile
	Local lRet		:= .F.
    Local lNewReg   := .F.
	Local lTamArq	:= .T.
    Local cProxObj  := ""
	Local cNameFile	:= ""
	Local cTextAux	:= ""
	Local cTamArq	:= ""
	Local cPathBco	:= ""
	Local nRet		:= 0
	Local nTamArq	:= 5242880 //5MB
	Local cArqTemp 	:= GetSrvProfString ("STARTPATH","")
	Local cBkpFil	:= cFilAnt

	DEFAULT cFileContent	:= ""
	DEFAULT cNameArq		:= ""
	DEFAULT cFileType		:= ""
	DEFAULT cError			:= ""
	DEFAULT cCodEmp			:= cEmpAnt

    cNameFile   := UPPER(cNameArq +"."+ cFileType)
	cArqTemp 	+= cNameFile
	cTextAux	:= Decode64( cFileContent )
    cPathBco	:= fGetPathBco(cCodEmp)

	If !File( cArqTemp )

		//Cria o arquivo temporario da imagem recebida pela requisicao
		nHandle 	:= FCREATE( cArqTemp )
		lContinua	:= !(nHandle == -1)
		cError		:= If( lContinua, "", EncodeUTF8( STR0015 ) + AllTrim(Str(Ferror())) ) //"Erro ao criar o arquivo temporário da imagem: "

		If lContinua
			FWrite(nHandle, cTextAux )
			FClose(nHandle)

			//Verifica o tamanho do arquivo
			oFile := FwFileReader():New(cArqTemp)
			If (oFile:Open())
				nRet := oFile:getFileSize()
				oFile:Close()
			EndIf

			lTamArq := nRet <= nTamArq

			//Cosidera somente imagens dentro do tamanho limite de 2MB
			If lTamArq

				cFilAnt  := SRA->RA_FILIAL
				cProxObj := GetSX8Num("ACB","ACB_CODOBJ")

				fExistFile(cPathBco, cNameArq, SRA->RA_FILIAL) //Elimina arquivo atual em caso de criaçao ou atualizacao do objeto

                //Faz a copia da origem, para a pasta do banco de conhecimento
                Copy File &(cArqTemp) To &(cPathBco + cNameFile)

                //Checa se o arquivo foi copiado com sucesso
                lContinua := File(cPathBco + cNameFile)

				Begin Transaction
					If lContinua

							DbSelectArea("ACB")
							ACB->(DbSetOrder(3))                
							lNewReg := !(ACB->(DbSeek(FWxFilial('ACB', SRA->RA_FILIAL) + cNameArq)))
							Reclock("ACB", lNewReg)
								ACB->ACB_FILIAL := FWxFilial('ACB', SRA->RA_FILIAL)
								ACB->ACB_OBJETO := UPPER(cNameFile)
								ACB->ACB_DESCRI := UPPER(cNameArq)
								ACB->ACB_CODOBJ := If( lNewReg, cProxObj, ACB->ACB_CODOBJ )
							ACB->(MsUnlock())
							
							//Cria o vinculo na tabela AC9
							DbSelectArea("AC9")
							AC9->(DbSetOrder(1))
							lNewReg := !(AC9->(DbSeek(FWxFilial('AC9', SRA->RA_FILIAL) + ACB->ACB_CODOBJ)))
							Reclock("AC9", lNewReg)
								AC9->AC9_FILIAL := FWxFilial('AC9', SRA->RA_FILIAL)
								AC9->AC9_ENTIDA := "SRA"
								AC9->AC9_FILENT := SRA->RA_FILIAL
								AC9->AC9_CODENT := SRA->RA_FILIAL + SRA->RA_MAT
								AC9->AC9_CODOBJ := If( lNewReg, cProxObj, AC9->AC9_CODOBJ )
							AC9->(MsUnlock())
							lRet := .T.

					EndIf
					cError := If( lRet, "", EncodeUTF8( STR0016 ) ) //"Ocorreu um erro durante a gravação no banco de conhecimento. Tente novamente e se o problema persistir contate o administrador do sistema"
					If(lRet, ConfirmSX8(), RollBackSx8())
				End Transaction
			EndIf

			Ferase(cArqTemp) //Elimina o arquivo temporario

			//"A imagem possui"#"e excede o tamanho máximo permitido:"
			cTamArq	:= EncodeUTF8( STR0017 ) +" ("+ cValToChar(nRet) +") Bytes, " + EncodeUTF8( STR0018 ) +" "+ cValToChar(nTamArq) + " Bytes (5MB)."
			cError	:= If( !lTamArq, cTamArq, cError)
		EndIf

	EndIf

	cFilAnt := cBkpFil

Return( lRet )

/*/{Protheus.doc} fInfBcoFile
Carrega as informacoes e/ou faz o download do anexo de uma solicitação
@author:	Marcelo Silveira
@since:		18/07/2022
@param:		nType - 1=Dados do arquivo, 2=arquivo para download;
			cFilRH3 - Filial da requisicao;
			cCodRH3 - Codigo da requisicao;
			cBranchVld - Filial do funcionario;
			cMatSRA - Matricula do funcionario;
			cNameArq - Nome do arquivo gerado;
			cType - Extensao do arquivo;
			cMsg - Erros ocorridos na extracao da imagem;
@return:	cReturn - Conteudo do arquivo			
/*/
Function fInfBcoFile( nType, cFilRH3, cCodRH3, cBranchVld, cMatSRA, cNameArq, cType, cMsg )

	Local oFile
	Local aArea			:= {}
	Local cArqTemp		:= ""
	Local cImg			:= ""
	Local cRet			:= ""
	Local lExist        := .F.
    Local lContinua		:= .T.

	DEFAULT cFilRH3		:= ""
	DEFAULT cCodRH3		:= ""
	DEFAULT cNameArq	:= ""
	DEFAULT cType		:= ""
	DEFAULT cMsg		:= ""

	//validação de segurança para acesso à informações do anexo
	If Empty(cBranchVld) .or. Empty(cMatSRA)
		cMsg      := EncodeUTF8( STR0019 ) //"usuário não informado!"
		lContinua := .F.
		cFilRH3   := ""
		cCodRH3   := ""
	EndIf

	If !Empty(cFilRH3) .And. !Empty(cCodRH3)

		aArea := GetArea()
		DbSelectArea("RH3")
		DbSetOrder(1)

		//valida permissão de acesso aos atestados quando esta sendo consultado por outra matricula
		If RH3->(Dbseek( cFilRH3 + cCodRH3 ) )
			If (RH3->RH3_FILIAL+RH3_MAT) != (cBranchVld+cMatSRA)
				// Somente checa permissão se não houver substituição, pois um substituto pode ser um surborinado do gestor.
				If Len( fGetSupNotify(cBranchVld, cMatSRA) ) == 0 .And. ;
				   !getPermission(cBranchVld, cMatSRA, RH3->RH3_FILIAL, RH3->RH3_MAT, , RH3->RH3_EMP)
					cMsg      := EncodeUTF8( STR0022 ) //"usuário não autorizado!"
					lContinua := .F.
				EndIf
			EndIf
		EndIf
		RestArea( aArea )

		If lContinua
			cArqTemp	:= cFilRH3 +"_"+ cCodRH3
			cImg		:= fGetByBco( cArqTemp, @cType, @cMsg, ,RH3->RH3_EMP )
			lExist		:= !Empty(cImg)

			If lExist
				oFile := FwFileReader():New(cImg)

				If (oFile:Open())
					cRet := oFile:FullRead()
					oFile:Close()

					If nType == 1
						//Retorna informacoes do arquivo
						cNameArq := cArqTemp
						cRet     := Encode64(cRet)
					Else
						//Retorna o arquivo para download
						cNameArq := cImg
					EndIf
				EndIf
			EndIf
			cMsg := If( lExist, "", EncodeUTF8( STR0020 ) ) //"O anexo da solicitação não foi localizado. Contate o administrador do sistema." )
		EndIf
		cMsg := If( lContinua, "", EncodeUTF8( STR0021 ) ) //"Este registro não possui a anexo"
	EndIf

Return( cRet )

/*/{Protheus.doc} fGetByReposit
Carrega as informacoes do anexo a partir do repositorio de imagens
@author:	Marcelo Silveira
@since:		18/07/2022
@param:		cNomeFile - Nome do arquivo para pesquisa no repositorio de imagens;
@return:	cRet - Conteudo do arquivo			
/*/
Function fGetByReposit(cNomeFile)

	Local cRet			:= ""
	Local cImg			:= ""
	Local cPathPict		:= ""
	Local cBkpMod		:= cModulo //Variável publica com o modulo que está startado. Por padrão em ambientes REST vem como FAT.
	Local oObjImg		:= Nil

	DEFAULT cNomeFile	:= ""

	If !Empty(cNomeFile)
		cModulo		:= "GPE"
		cPathPict	:= GetSrvProfString ("STARTPATH","")

		//Instancia o objeto da imagem
		oObjImg := FwBmpRep():New()

		//Extrai o arquivo
		oObjImg:Extract( cNomeFile, cPathPict+cNomeFile )

		Do Case
			Case File( (cImg := cPathPict+cNomeFile) + ".jpg" )
				cRet := cImg += ".jpg"
			Case File( (cImg := cPathPict+cNomeFile) + ".bmp" )
				cRet := cImg += ".bmp"
		End Case

		cModulo := cBkpMod //Volta ao modulo original
	EndIf

Return( cRet )

/*/{Protheus.doc} fGetByBco
Carrega as informacoes do anexo a partir do banco de conhecimento
@author:	Marcelo Silveira
@since:		18/07/2022
@param:		cNomeFile - Nome do arquivo para pesquisa no banco de conhecimento;
@return:	cRet - Conteudo do arquivo			
/*/
Function fGetByBco(cArqTemp, cType, cMsg, lPdf, cCodEmp)

	Local cRet			:= ""
	Local cNameFile		:= ""
	Local cPathBco		:= ""

	DEFAULT cArqTemp	:= ""
	DEFAULT cType		:= ""
	DEFAULT cMsg		:= ""
	DEFAULT lPdf		:= .F.
	DEFAULT cCodEmp		:= cEmpAnt

	If !Empty(cArqTemp)
		cPathBco    := fGetPathBco(cCodEmp)
		cNameFile   := cPathBco + cArqTemp

		Do Case
			Case File( (cRet := cNameFile) + ".JPG" )
				cType 	:= "jpg"
				cRet 	+= ".jpg"
			Case File( (cRet := cNameFile) + ".PDF" )
				cType 	:= "pdf"
				cRet 	+= ".pdf"
				lPdf	:= .T.
			Case File( (cRet := cNameFile) + ".PNG" )
				cType 	:= "png"
				cRet 	+= ".png"
			Case File( (cRet := cNameFile) + ".JPEG" )
				cType 	:= "jpeg"
				cRet 	+= ".jpeg"
		End Case
	EndIf

	//Se não existe extensão indica que o arquivo não existe
	cRet := If( Empty(cType), "", cRet )

Return( cRet )

/*/{Protheus.doc} fExistFile
Elimina o arquivo existente no banco de conhecimento em caso de inclusão ou atualizacao
@author:	Marcelo Silveira
@since:		18/07/2022
@param:		cNomeFile - Path para pesquisa no banco de conhecimento;
			cObjeto - Nome do arquivo
@return:	Nil	
/*/
Function fExistFile(cPath, cObjeto, cFilFun)

	DEFAULT cFilFun := cFilAnt 

	DbSelectArea("ACB")
	ACB->(DbSetOrder(3))                
	If ACB->(DbSeek(FWxFilial('ACB', cFilFun) + cObjeto))
		If File( cPath + ACB->ACB_OBJETO )
			Ferase(cPath + ACB->ACB_OBJETO)
		EndIf		
	EndIf

Return()

/*/{Protheus.doc} fChkDirDoc
Verifica se existe a estrutura do Banco de conhecimento e cria a estrutura caso nao exista
@author:	Marcelo Silveira
@since:		21/07/2022
@param:		cPath - Path para verificacao;
@return:	Nil	
/*/
Function fChkDirDoc(cPath)

Local nX		:= 0
Local cIniPath	:= "\"
Local aDir		:= {}
Local lChkOk	:= .F.

lChkOk := ExistDir( cPath  )

If !lChkOk .And. !Empty(cPath)	
	aDir := STRTOKARR( cPath, "\" )
	For nX := 1 To Len(aDir)
		If !ExistDir( cIniPath + aDir[nX]  )
			MakeDir( cIniPath + aDir[nX] )
		EndIf
		cIniPath += aDir[nX] + "\"
	Next nX
EndIf

Return()


/*/{Protheus.doc} fDelObj
Deleta um objeto do banco de conhecimento
@author:	Henrique Ferreira
@since:		01/08/2022
@param:		cCodFil 	- Coódigo da Filial;
			cDescObj	- Descrição do objeto para busca
@return:	Nil	
/*/
Function fDelBcoFile(cCodEmp, cCodFil, cDescObj)

Local aArea		:= GetArea()
Local cCodObj	:= ""
Local cKey		:= ""
Local cPathBco	:= ""

DEFAULT cCodEmp	 := cEmpAnt
DEFAULT cCodFil  := cFilAnt
DEFAULT cDescObj := ""

If !Empty(cCodFil) .And. !Empty(cDescObj)
	
	cPathBco := fGetPathBco(cCodEmp)
	//ACB_FILIAL+ACB_DESCRI
	cKey := xFilial( "ACB", cCodFil ) + cDescObj
	dbSelectArea("ACB")
	dbSetOrder(3)
	If ACB->( dbSeek( cKey ) )
		Begin Transaction

			cCodObj := ACB->ACB_CODOBJ

			// Deleta o arquivo físico na pasta.
			fExistFile( cPathBco, cDescObj, cCodFil )

			// Deleta os registros no banco de dados.
			RecLock("ACB",.F.)
			ACB->(dbDelete())
			ACB->(MsUnlock())

			// AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
			cKey := xFilial( "AC9", cCodFil ) + cCodObj + "SRA" + cCodFil
			DbSelectArea("AC9")
			AC9->( dbSetOrder(1) )
			If AC9->( dbSeek(cKey) )
				RecLock("AC9",.F.)
				AC9->(dbDelete())
				AC9->(MsUnlock())
			EndIf
		End Transaction
	EndIf
EndIf

RestArea(aArea)

Return()

/*/{Protheus.doc} fDelImgRep
Deleta uma imagem do repositório de imagens
@author:	Henrique Ferreira
@since:		01/08/2022
@param:		cCodFil 	- Coódigo da Filial;
			cDescObj	- Descrição do objeto para busca
@return:	Nil	
/*/
Function fDelImgRep( cArqName )

Local aArea		:= GetArea()
Local oImg		:= NIL

DEFAULT cArqName := ""	 

If !Empty( cArqName )
	oImg := FWBmpRep():New()
	If oImg:OpenRepository()
		If oImg:ExistBmp( cArqName )
			oImg:DeleteBmp( cArqName )
		EndIf
		oImg:CloseRepository()
	EndIf
EndIf

RestArea(aArea)

Return()
