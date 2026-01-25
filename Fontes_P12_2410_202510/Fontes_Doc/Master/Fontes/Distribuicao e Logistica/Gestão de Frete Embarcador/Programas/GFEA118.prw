#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"
#include "FILEIO.CH"

#DEFINE DIRXML  "XMLNFE\"
#DEFINE DIRALER "NEW\"
#DEFINE DIRLIDO "OLD\"
#DEFINE DIRERRO "ERR\"
#DEFINE DIRXMLLNX  "xmlnfe\"
#DEFINE DIRALERLNX "new\"
#DEFINE DIRLIDOLNX "old\"
#DEFINE DIRERROLNX "err\"
#DEFINE TOTVS_COLAB_ONDEMAND 3100
#DEFINE SB2 Replicate(' ', 2)
#DEFINE SB4 Replicate(' ', 4)
#DEFINE SB6 Replicate(' ', 6)
#DEFINE SB8 Replicate(' ', 8)
#DEFINE SB15 Replicate(' ', 15)

Static __lCpoSr := Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118

Importação do Documento de Frete  através do Totvs Colaboração

@author Felipe rafael mendes
@since 23/06/10
@version 1.0 
/*/
//-------------------------------------------------------------------
Function GFEA118()
	Private oBrowse115

	oBrowse115 := FWMarkBrowse():New()
	oBrowse115:SetAlias("GXG")
	oBrowse115:SetMenuDef("GFEA118")
	oBrowse115:SetFieldMark("GXG_MARKBR")
	oBrowse115:SetDescription( "Recebimento de Documento de Frete") // "Recebimento de Documento de Frete"
	oBrowse115:SetAllMark({|| GFEA118MARK()})

	oBrowse115:SetFilterDefault("GXG_ORIGEM == '2'")

	oBrowse115:AddLegend("GXG_EDISIT == '1'", "BLUE"   	, "Importado" )          // "Importado"
	oBrowse115:AddLegend("GXG_EDISIT == '2'", "YELLOW"	, "Importado com erro" ) // "Importado com erro"
	oBrowse115:AddLegend("GXG_EDISIT == '3'", "RED"    	, "Rejeitado" )          // "Rejeitado"
	oBrowse115:AddLegend("GXG_EDISIT == '4'", "GREEN"	, "Processado" )         // "Processado"
	oBrowse115:AddLegend("GXG_EDISIT == '5'", "BLACK"	, "Erro Impeditivo" )    // "Erro Impeditivo"

	oBrowse115:Activate()
Return(Nil)
//-------------------------------------------------------
//	MenuDef
//-------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"         ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar"        ACTION "VIEWDEF.GFEA118" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Importar"          ACTION "GFEA118IMP()"    OPERATION 3 ACCESS 0 // "Importar"
	ADD OPTION aRotina TITLE "Alterar"           ACTION "VIEWDEF.GFEA118" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE "Processar"         ACTION "GFEA115PRO('3')" OPERATION 4 ACCESS 0 // "Processar"
	ADD OPTION aRotina TITLE "Excluir"           ACTION "VIEWDEF.GFEA118" OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE "Exc. Selecionados" ACTION "GFEA118PrE()"    OPERATION 5 ACCESS 0 // "Excluir Todos"
	ADD OPTION aRotina TITLE "Selecionar todos"  ACTION "GFEA118MKT()"    OPERATION 5 ACCESS 0 // "Selecionar todos"
	ADD OPTION aRotina TITLE "Imprimir"          ACTION "VIEWDEF.GFEA118" OPERATION 8 ACCESS 0 // "Imprimir"
Return aRotina
//-------------------------------------------------------
//Função ModelDef
//-------------------------------------------------------
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructGXG := FWFormStruct(1,"GXG")
	Local oStructGXH := FWFormStruct(1,"GXH")

	oStructGXH:SetProperty("GXH_NRIMP", MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= GXG->GXG_NRIMP,FWCloseCpo(a,b,c,.t.),lRetorno } )
	oModel := MPFormModel():New("GFEA118", /*bPre*/, {|oX| GFEA118PV(oX) }/*bPost*/,/*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEA118_GXG", Nil, oStructGXG,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("GFEA118_GXH","GFEA118_GXG",oStructGXH,/*bLinePre*/,/*{ | oX | GFE103BW( oX ) }*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA118_GXH",{{"GXH_FILIAL",'GXG_FILIAL'},{"GXH_NRIMP","GXG_NRIMP"}},"GXH_NRIMP+GXH_SEQ")
	oModel:GetModel("GFEA118_GXH"):SetDelAllLine(.T.)
	oModel:SetOptional("GFEA118_GXH", .T. )
Return oModel
//-------------------------------------------------------
//Função ViewDef
//-------------------------------------------------------
Static Function ViewDef()
	Local oModel     := FWLoadModel("GFEA118")
	Local oView      := Nil
	Local oStructGXG := FWFormStruct(2,"GXG")
	Local oStructGXH := FWFormStruct(2,"GXH")

	oStructGXG:SetProperty( "GXG_ALTER"  , MVC_VIEW_CANCHANGE ,.F.)
	oStructGXG:SetProperty( "GXG_ACAO"   , MVC_VIEW_CANCHANGE ,.F.)
	If GFXCP12131("GXG_MUNINI")
		oStructGXG:SetProperty( "GXG_MUNINI"  , MVC_VIEW_CANCHANGE ,.F.)
		oStructGXG:SetProperty( "GXG_UFINI"   , MVC_VIEW_CANCHANGE ,.F.)
		oStructGXG:SetProperty( "GXG_MUNFIM"  , MVC_VIEW_CANCHANGE ,.F.)
		oStructGXG:SetProperty( "GXG_UFFIM"   , MVC_VIEW_CANCHANGE ,.F.)
	EndIf
	oStructGXG:RemoveField("GXG_MARKBR")
	oStructGXH:RemoveField("GXH_CNPJEM")

	If GFXCP2510("GXG_XMLTRB")
		oStructGXG:RemoveField("GXG_XMLTRB")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField( "GFEA118_GXG" , oStructGXG )
	oView:AddGrid( "GFEA118_GXH" , oStructGXH )

	oView:CreateHorizontalBox( "MASTER" , 55 )
	oView:CreateHorizontalBox( "DETAIL" , 45 )

	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Doc Carga")

	oView:CreateHorizontalBox( "DETAILFAI"  , 100,,,"IDFOLDER","IDSHEET01" )
	oStructGXH:RemoveField("GXH_NRIMP")

	oView:AddIncrementField("GFEA118_GXH","GXH_SEQ")

	oView:SetOwnerView( "GFEA118_GXG" , "MASTER" )
	oView:SetOwnerView( "GFEA118_GXH" , "DETAILFAI" )

	oView:SetCloseOnOk({|| GFEA118PS(oModel, oView)})
	oView:AddUserButton( 'Consultar Doc Frete', 'MAGIC_BMP', {|oModel| GFEA118GW3(FwFldGet("GXG_CTE"))} )
Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA115PS
Rotina de Pos validação
Uso Geral.

@author Felipe Rafael Mendes
@since 22/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA118PS(oModel, oView)
	Local nOpc := (oModel:GetOperation())

	If nOpc == MODEL_OPERATION_UPDATE .And. oView:lModify
		RecLock("GXG",.F.)
		GXG->GXG_ALTER := "1"
		GXG->(MsUnlock())
		Return .T.
	EndIf

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118PrE
Processa Exclusão dos registros

@author Fabio Marchiori Sampaio
@since 19/08/2022
@version 1.0
/*/
//-------------------------------------------------------------------  
Function GFEA118PrE()

	If MsgYesNo("Excluir os registros importados selecionados?")
		FwMsgRun( , { || lRet:= GFEA118DEL() }  , ,  'Excluindo registros selecionados...' )
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118DEL
Eliminação dos registros importados selecionados

@author Israel A. Possoli
@since 26/06/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA118DEL(cChaveCte)
	Local cNrDf     := ""
	Local cWhere	:= "%"
	Local cAliasGXG := GetNextAlias()
	Local cAliasGXH := GetNextAlias()
	Default cChaveCte := ""

	If IsBlind() .Or. IsInCallStack("SCHEDCOMCOL")
		If ValType(XmlChildEx(oCTe,"_EVENTOCTE")) == "O" // Evento de cancelamento
			cChaveCte := SubStr(oCTe:_EVENTOCTE:_INFEVENTO:_CHCTE:TEXT,0,44)
		Else
			cChaveCte := SubStr(oCTe:_INFCTE:_ID:TEXT,4,44)
		EndIf
		cWhere += "AND GXG.GXG_CTE =" + "'" + cChaveCte + "'"
		cWhere += "%"
	Else
		If !Empty(cChaveCte)
			cWhere += "AND GXG.GXG_CTE =" + "'" + cChaveCte + "'"
			cWhere += "%"
		Else
			cWhere += "AND GXG.GXG_MARKBR =" + "'" + oBrowse115:Mark() + "'"
			cWhere += "%"
		EndIf
	EndIF

	// Busca informações do documento de frete para serem removidos
	BeginSql Alias cAliasGXG
		SELECT GXG.R_E_C_N_O_ RECNOGXG,
			   GXG.GXG_FILIAL,
			   GXG.GXG_NRIMP
		FROM %Table:GXG% GXG
		WHERE GXG.GXG_FILIAL = %xFilial:GXG%
		AND   GXG.%NotDel%
		%Exp:cWhere%
	EndSql

	//  Busca documento de carga relacionado ao doc de frete
	BeginSql Alias cAliasGXH
		SELECT GXG.GXG_FILIAL,
			GXG.GXG_NRIMP,
			GXH.GXH_FILIAL,
			GXH.GXH_NRIMP,
			GXH.GXH_SEQ
		FROM %Table:GXG% GXG
		INNER JOIN %Table:GXH% GXH
		ON    GXH.GXH_FILIAL = GXG.GXG_FILIAL
		AND   GXH.GXH_NRIMP  = GXG.GXG_NRIMP
		AND   GXH.%NotDel%
		WHERE GXG.GXG_FILIAL = %xFilial:GXG%
		AND   GXG.%NotDel%
		%Exp:cWhere%
	EndSql

	Do While (cAliasGXG)->(!Eof())

		// Remove o Documento de carga
		While (cAliasGXH)->(!Eof())
			GXH->(dbSetOrder(1))
			GXH->(dbSeek((cAliasGXH)->GXH_FILIAL + (cAliasGXH)->GXH_NRIMP + (cAliasGXH)->GXH_SEQ))
			RecLock("GXH", .F.)
			GXH->(dbDelete())
			GXH->(MsUnlock())
			(cAliasGXH)->(dbSkip())
		EndDo

		If GFXCP12131("GZZ_NRDF") .And. GXG->GXG_EDISIT != "4"
			cNrDf := GFE118ZRGW3(ALLTRIM(GXG->GXG_NRDF), GXG->GXG_CDESP)

			dbSelectArea("GZZ")
			GZZ->(dbSetOrder(1))
			GZZ->(dbSeek(GXG->GXG_FILDOC + GXG->GXG_CDESP + GXG->GXG_EMISDF + GXG->GXG_SERDF + GXG->GXG_NRDF + DTOS(GXG->GXG_DTEMIS)))
			While !GZZ->( Eof() ) .And. GZZ->GZZ_FILIAL == GXG->GXG_FILDOC .And. GZZ->GZZ_CDESP == GXG->GXG_CDESP ;
					.AND. GZZ->GZZ_EMISDF == GXG->GXG_EMISDF .And. GZZ->GZZ_SERDF == GXG->GXG_SERDF ;
					.AND. GZZ->GZZ_NRDF == GXG->GXG_NRDF .And. DTOS(GZZ->GZZ_DTEMIS) == DTOS(GXG->GXG_DTEMIS)

				RecLock("GZZ",.F.)
				dbDelete()
				GZZ->(MsUnLock("GZZ"))
				GZZ->( dbSkip() )
			EndDo
		EndIF
		// Remove o documento de frete
		GXG->(dbGoTo((cAliasGXG)->RECNOGXG))
		RecLock("GXG", .F.)
		GXG->(dbDelete())
		GXG->(MsUnlock())
		(cAliasGXG)->(dbSkip())
	EndDo

	(cAliasGXH)->(dbCloseArea())
	(cAliasGXG)->(dbCloseArea())

	If !IsBlind() .And. !IsInCallStack("SCHEDCOMCOL")
		oBrowse115:Refresh()
		oBrowse115:GoTop(.T.)
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118IMP

Chamada para importação

@author Ana Claudia da Silva
@since 30/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA118IMP()
	If IsBlind()
		GFEA1181P1()
	Else
		Processa({|| GFEA1181P1()},"Importando arquivos", "")
	EndIf
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA1181P1

Verica o caminho que esta sendo importado, e se é um arquivo nao valido
coloca o nome do arquivo num relatório de erro ao final da importação

@author Ana Claudia da Silva
@since 30/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA1181P1()
//TC 2.0
	Local lTC20     := GA118TC20()  //Indica se Totvs Colaboração 2.0
	Local lContinua := .T.
	Local lIsLinux  := IsSrvUnix()
	Local aProc     := {}
	Local aErros    := {}
	Local cDirXML   := ""
	Local cDirLido  := ""
	Local cDirErro  := ""
	Local nCont     := 0
	Local nFCont    := 0

	Private GFEResult   := GFEViewProc():New()
	Private lImportaCte := .F.

	/*Verifica se é Totvs Colaboração 1.0 ou 2.0
	Para TC 1.0 haverá diretórios de arquivos, lidos, e de erro.
	Para TC 2.0 haverá diretórios de arquivos, e lidos.*/
	If lTC20
		//Verifica se a empresa tem licença pro TC 2.0
		If !FWLSEnable(TOTVS_COLAB_ONDEMAND) .And. !FwEmpTeste()
			
			GFEHelp("Ambiente não licenciado para o modelo TOTVS Colaboração 2.0.",,,.F.)
			lContinua := .F.
		EndIf
		If lContinua
			cDirXML  := GFEA118Bar(AllTrim(GetNewPar("MV_NGINN","\NeoGrid\IN\")))
			cDirLido := GFEA118Bar(AllTrim(GetNewPar("MV_NGLIDOS","\NeoGrid\LIDOS\")))

			If !IsBlind()
				cDirErro := cDirXML + If(lIsLinux, DIRERROLNX, DIRERRO)
				If !ImpExpMng(@cDirXML,@cDirLido,@cDirErro)
					lContinua := .F.
				EndIf
			Else
				If !GA118CrDir(cDirXML)
					lcontinua := .F.
				EndIf
				If !GA118CrDir(cDirLido)
					lContinua := .F.
				EndIf
			EndIF
			If lContinua
				aDirImpor := DIRECTORY(AllTrim(cDirXML) + "214*.XML" ) //somente arquivos de recebimento de CTe
				aDirCanc  := DIRECTORY(AllTrim(cDirXML) + "384*.XML" ) //somente arquivos de cancelamento de CTe por evento
				If Empty(aDirCanc)
					aDirCanc := DIRECTORY(AllTrim(cDirXML) + "383*.XML" ) //somente arquivos de cancelamento de CTe por evento
				EndIf
				
				For nCont := 1 to Len(aDirCanc)
					AADD(aDirImpor, aDirCanc[nCont])
				Next aDirImpor

				If Len(aDirImpor) < 1
					GFEHelp( "Não foram encontrados arquivos XML válidos no diretório " + cDirXML + ".",,,.F.)
					lcontinua := .F.
				EndIf
			EndIf
		EndIf
	Else
		//Verifica e cria, se necessário, a estrutura de diretórios
		cDirXML := GFEA118Bar(AllTrim(SuperGetMv("MV_XMLDIR", .F., "")))

		If Empty(cDirXML) .And. IsBlind()
			GFEHelp( "Não foi especificado um diretório para importação no parâmetro " + cParDir + ".",,,.F.)
			lContinua := .F.
		EndIF
		If lContinua
			cDirLido  := cDirXML + If(lIsLinux, DIRLIDOLNX, DIRLIDO)
			cDirErro  := cDirXML + If(lIsLinux, DIRERROLNX, DIRERRO)

			If !IsBlind()
				If !ImpExpMng(@cDirXML,@cDirLido,@cDirErro)
					lContinua := .F.
				EndIF
			Else
				If !GA118CrDir(cDirXML)
					lContinua := .F.
				EndIf
				If !GA118CrDir(cDirLido)
					lcontinua := .F.
				EndIf
				If !GA118CrDir(cDirErro)
					lContinua := .F.
				EndIf
			EndIf
			If lContinua
				If !lIsLinux
					aDirImpor := DIRECTORY(Alltrim(cDirXML) + "*.XML" )
				Else
					aDirImpor := {}
					aAuxDir := DIRECTORY(Alltrim(cDirXML) + "*.*", , ,.F.)	// Para leitura de arquivos que possuam caracter maiusculo na extensão
					For nCont := 1 to Len(aAuxDir)
						fRename( Alltrim(cDirXML)+aAuxDir[nCont][1], Lower(Alltrim(cDirXML)+aAuxDir[nCont][1]) , NIL , .F. )
						aAuxDir[nCont][1] := lower(aAuxDir[nCont][1])
						AADD(aDirImpor, aAuxDir[nCont])
					Next
				EndIf
				If Len(aDirImpor) < 1
					GFEHelp( "Não foram encontrados arquivos XML no diretório " + cDirXML + ".",,,.F.)
					lContinua := .F.
				Endif
			EndIf
		EndIf
	EndIf
	If lContinua
		cDirXML  := AllTrim(cDirXML)
		cDirLido := AllTrim(cDirLido)
		cDirErro := AllTrim(cDirErro)

		If !IsBlind()
			ProcRegua(0)
		EndIf
		nFCont := Len(aDirImpor)
		For nCont := 1 to nFCont
			If lIsLinux .And. !( ".xml" $ Alltrim(Lower(aDirImpor[nCont][1])) )
				loop
			EndIf

			cXMLArq := cDirXML + aDirImpor[nCont][1]

			//Quando a tabela GXG for compartilhada o programa rodará normalmente.
			//Quando a tabela GXG for Exclusiva só será feita a importação dos arquivos que forem da
			//filial corrente, os arquivos que não forem da filial corrente não serão alterados.
			//Para TC 2.0:
			//Quando executado via GFEA118, o arquivo deverá existir. Assim, o GFEA118 moverá o arquivo para pasta lidos.
			//Quando executado via ComXCol, o Job ColAutoRead "consome" o arquivo, criando um registro na
			//tabela CKO, e move o arquivo para pasta lidos. O Job SchdComCol fará a leitura dos registros dessa tabela,
			//para então chamar o GFEA118, que não irá mover o arquivo, apenas criar os registros GXG e GXH.

			//Só retornará falso quando o arquivo for inválido
			If !GFEA118CHA(cXMLArq,@aProc,@aErros,cDirLido,cDirErro)
				If lTC20 .And. IsBlind()
					GA118MoveFile(cXMLArq, cDirLido + aDirImpor[nCont][1])
				Else
					GA118MoveFile(cXMLArq, cDirErro + aDirImpor[nCont][1])
				EndIf
			EndIf

			If !IsBlind()
				IncProc(aDirImpor[nCont][1])
			EndIf
		Next nCont

		If SuperGetMV('MV_IMPPRO',,'1') == '2'
			GFEA115PRO()
		EndIf

		If Len(cXMLArq) > 0 .And. !lImportaCte
			MsgInfo("Não foram encontrados arquivos para a filial corrente. Para importar"+;
			" arquivos de todas as filiais altere o modo de acesso de filiais das tabelas GXG e GXH para compartilhado.")
		EndIf

		If !IsBlind() .And. !Empty(aErros)
			nFCont := Len(aErros)
			For nCont := 1 To nFCont
				GFEResult:AddErro("Arquivo: " + aErros[nCont][1] + CRLF + aErros[nCont][2])
				GFEResult:AddErro(Replicate("-",50) + CRLF)
			Next nCont

			GFEResult:AddErro("Ocorreram erros na importação de um ou mais arquivos. Possíveis motivos:" + CRLF + "- Erros nos arquivos XML;" + CRLF + "- Arquivos incompatíveis com o formato XML;" + CRLF + "- Chave de CTE já importada/processada." + CRLF)
			GFEResult:Show("Importação de arquivos Ct-e", "Arquivos", "Erros", "Clique no botão 'Erros' para mais detalhes.")
		EndIf
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118CHA

Verifica o caminho que está sendo importado, verifica se é valido ou nao se
for continua o processo se nao vai para lista de arquivos com erro.

@param cXMLFile caminho do arquivo que esta sendo importado
@param aErros  armazena o caminho dos aquivos com erro
@param aProc   array para guardar os arquivos processados (M-Mess)

@author Ana Claudia da Silva
@since 30/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA118CHA(cXMLFile,aProc,aErros,cDirLido,cDirErro,aErroERP)
	Local lRet      := .T.
	Local cError    := ""
	Local cWarning  := ""
	Local nHandle   := 0

	Default aProc     := {}
	Default aErros    := {}
	Default aErroERP  := {}
	Private oXML      := NIL
	Private cBuffer   := ''
	Private nSize     := 0

	Private cBufSTR   := ""

	nHandle := FOpen(cXMLFile,FO_READ+FO_SHARED) //Parametros: Arquivo, Leitura - Escrita, Servidor
	If nHandle < 0
		cError := str(FError())
		aAdd(aErros,{cXMLFile,"Erro ao abrir arquivo: ( " + cError + CHR(13)+CHR(10), ")" + GFERetFError(FError())})
		lRet := .F.
	EndIf
	If lRet
		nSize := FSeek(nHandle,FS_SET,FS_END)
		FSeek(nHandle,0)
		FRead(nHandle,@cBuffer,nSize)

		oXML  := XmlParser( cBuffer , "_", @cError, @cWarning)

		cBufSTR := cBuffer

		FClose(nHandle)
		nHandle   := -1

		If ValType(oXML)=="O"
			If ValType(XmlChildEx(oXML,"_CTEPROC")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_VERSAO")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_VERSAO")) == "O"  //-- Validar versão CTe
				If oXML:_CTeProc:_VERSAO:TEXT < "3.00"
					cError := "Versão do CT-e invalida."
					aAdd(aErros,{cXMLFile,"Erro >> Arquivo: " + cError + CHR(13)+CHR(10), ""})
					Return lRet := .F.
				EndIf
			EndIf		
			If ValType(XmlChildEx(oXML,"_CTEPROC")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_CTE")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_VERSAO")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_PROTCTE")) == "O" //-- Arquivo de RETORNO de Nota de transporte
				GFEA118XML(cXMLFile,cDirLido,cDirErro,@aProc,@aErros,oXML:_CTeProc:_Cte,.F.,oXML:_CTeProc:_ProtCte,@aErroERP)
			ElseIf ValType(XmlChildEx(oXML,"_CTEPROC")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_ENVICTE")) != "U" .And. ValType(XmlChildEx(oXML:_CTeProc:_ENVICTE,"_CTE")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_VERSAO")) == "O" .And. ValType(XmlChildEx(oXML:_CTeProc,"_PROTCTE")) == "O"
				GFEA118XML(cXMLFile,cDirLido,cDirErro,@aProc,@aErros,oXML:_CTeProc:_ENVICTE:_Cte,.F.,oXML:_CTeProc:_ProtCte,@aErroERP)
			ElseIf ValType(XmlChildEx(oXML,"_ENVICTE")) == "O" .And. ValType(XmlChildEx(oXML:_enviCTe,"_CTE")) != "U" .And. (ValType(XmlChildEx(oXML:_enviCTe,"_CTE")) == "O" ) //-- Arquivo de Evento Cte
				GFEA118XML(cXMLFile,cDirLido,cDirErro,@aProc,@aErros,oXML:_enviCTe:_Cte,.F.)
			ElseIf ValType(XmlChildEx(oXML,"_ENVICTE")) == "O" .And. ValType(XmlChildEx(oXML:_enviCTe,"_CTE")) != "U" .And. (ValType(XmlChildEx(oXML:_enviCTe,"_CTE")) == "A" ) //-- Arquivo de Evento Cte
				GFEA118XML(cXMLFile,cDirLido,cDirErro,@aProc,@aErros,oXML:_enviCTe:_Cte[1],.F.)
			ElseIf ValType(XmlChildEx(oXML,"_CTE")) == "O" //-- Arquivo de REMESSA de Nota de transporte
				GFEA118XML(cXMLFile,cDirLido,cDirErro,@aProc,@aErros,oXML:_Cte,.F.)
			ElseIf ValType(XmlChildEx(oXML,"_PROCEVENTOCTE")) == "O" //-- Arquivo de RETORNO de Evento Cte/Cancelamento
				GFEA118XML(cXMLFile,cDirLido,cDirErro,@aProc,@aErros,oXML:_procEventoCTe,.F.)
			Else
				If cError = ''
					cError := 'Arquivo com tag principal inválida.'
				EndIf

				aAdd(aErros,{cXMLFile,"Erro >> Arquivo: " + cError + CHR(13)+CHR(10), ""})
				lRet := .F.
			EndIf
		EndIf
		oXML := Nil
		DelClassIntF()
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118XML

Validações do arquivo Cte

@param cXMLFile caminho do arquivo que esta sendo importado
@param aErros  armazena o caminho dos aquivos com erro
@param aProc   array para guardar os arquivos processados (M-Mess)
@param oXml: Objeto XML do CTE
@param lTotvsColab: se a chamada da função vem do COMXCOL (importação via TSS/Totvs Colaboração)

@author Ana Claudia da Silva
@since 30/09/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA118XML(cXMLFile,cDirLido,cDirErro,aProc,aErros,oXML,lTotvsColab, oProtCte,aErroERP,lComxcol)
	Local lNrDf          := .F.
	Local lApuIcm        := .F.
	Local lFindGW1       := .T.
	Local lGravaGXG      := .T.
	Local lTC20          := GA118TC20() //Indica se Totvs Colaboração 2.0
	Local lRetFuncao     := .T. //retorno desta função.
	Local lMoveArq       := .T. //indica se deverá ser feita movimentação (cópia/exclusão) do arquivo.
	Local lProcArq       := .T. //indica se deve continuar o processamento do arquivo. Serve para, mesmo após processar o arquivo, gravar logs e eliminar variáveis da memória
	Local lCteOutFil     := .F. //indica se CTe é de outra filial.
	Local lRetEdiSit     := .T.
	Local lProtInv       := .T.
	Local lContinua      := .T.
	Local lIsLinux       := IsSrvUnix()
	Local lArrayCTe      := .F.
	Local aGUT           := Array(2)
	Local aVldNF         := {} // Hierarquia de validação da tag NF
	Local aTemp          := {}
	Local aOriDoc        := {'','',.F.} // Uso da substituição cte
	Local aRetICMS       := Array(4)
	Local aExcStat       := {"100","102","103","104","105","106","107","108","109","110","111","112","113","114","134","135","136","301"}
	Local oInfNFE        := Nil // Tag infNFe
	Local oInfNF         := Nil // Tag infNF
	Local oinfOutros     := Nil // Tag infOutros
	Local oDocAnt        := Nil // Tag DocAnt
	Local oCTeAnt        := Nil // Tag chCTe
	Local cAliasGW3      := Nil
	Local cAliasGXG      := Nil
	Local cAliasGXH      := Nil
	Local cAliasGW4      := Nil
	Local cAliasGU3      := Nil
	Local cAliasGU7      := Nil
	Local cAliasGUT      := Nil
	Local cFilEmit       := ''
	Local cFilVal        := ''
	Local cFilGW1        := ''
	Local cComp          := ''
	Local cChaveRel      := ''
	Local cCgcRem        := ''
	Local codCidIni      := 0
	Local codCidFim      := 0
	Local codUFIni       := ""
	Local codUFFim       := ""
	Local cVTPrest       := ''
	Local cVRec          := ''
	Local cToma          := ''
	Local cCliDes        := ''
	Local cCliIdFed      := ''
	Local cCliDesFed     := ''
	Local cLock          := ''
	Local cLockTime      := ''
	Local cDoc           := ''
	Local cSerie         := ''
	Local cObs           := ''
	Local cUFOrigem      := ''
	Local cStat          := ''
	Local cMV_GFEVPRT    := SuperGetMV('MV_GFEVPRT',,'1')
	Local cMOtivo        := ''
	Local cChaveCte      := ''
	Local cEmiProc       := ''
	Local xMotivo        := Nil
	Local nRecnoGW1      := 0
	Local nCont          := 0
	Local nFCont         := 0
	Local nContId        := 0
	Local nFCont2         := 0
	Local nContId2        := 0
	Local nVlTaxas       := 0
	Local nPos           := 0
	Local nTipoXML       := 0
	Local nCountZerosNF  := 0
	Local nX             := 0
	Local nNF            := 0
	Local nPossuiIcms    := 0
	Local nSeq           := 0
	Local dvlIcmsTRet    := ''
	Local dvCred         := ''
	Local nGXG_NRIMP     := TamSx3("GXG_NRIMP")[1]
	Local cNrDF   	 	 := ''
	Local lDocAntEle     := .F.
	Local nDocAntEle     := 0
	Local aRetCte        := {}
	Local cChaveCteSub	 := ''

	Default lTotvsColab  := .T. // Parametro não é informado passado na chamada pela função COMXCOL (Materiais)
	Default aProc        := {}
	Default aErros       := {}
	Default aErroERP     := {}

	Private cEmi         := ''
	Private aGXG         := Array(40)
	Private cMsgPreVal   := ''
	Private cMsgAux      := ''
	Private oCTe         := Nil
	Private cDIROK       := ''
	Private cDirDest     := ''
	Private s_INTTMS     := SuperGetMv("MV_INTTMS", .F., .F.)
	Private s_TMSGFE     := SuperGetMv("MV_TMSGFE", .F., .F.)
	Private GFELog118    := GFELog():New("gfea118", "CTe Importação", SuperGetMV('MV_GFEEDIL',,'1'))
	Private cTpCte       := ""
	Private cTpServ      := ""
	Private cAliasGW1    := Nil
	Private aGXH         := {}	
	Private	nAuxCidIni 	 := 0
	Private	nAuxCidFim 	 := 0
	Private cAuxUFIni	 := ""
	Private cAuxUFFim 	 := ""

	Private nPosAux    := 0
	Private cAuxCodFil := ""
	Private aAllFil    := FWLoadSM0()


	lComxcol    := .F.
	oCTe        :=  oXML
	lTotvsColab := (lTotvsColab .Or. IsInCallStack("COMXCOLImp")) // Validar se COMXCOLImp ainda é usado

	//Ponto de entrada Embramaco
	//Não integra CTE com GFE via Totvs Colaboração
	If ExistBlock("GFEA1186")
		lRet := ExecBlock("GFEA1186")
		If lRet
			cMsgPreVal := ""
			lComxcol   := .T.
			lProcArq   := .F.
			Return lRet
		EndIf
	EndIf

	GFELog118:Add('HORA         MENSAGEM')
	GFELog118:Add(Replicate('-', 12) + ' ' + Replicate('-',107))

	cLock := 'GFEA118_' + GA118ExtDirOrFileName(cXMLFile,2) //inclui GFEA118_ para evitar uma possível concorrência com outros programas

	//Inclui semáforo para evitar de um arquivo ser importado mais de uma vez por processos executados em paralelo.
	If LockByName(cLock, .F., .F.)
		GFELog118:Add(GFENOW(.F.,,,':','.') + ' - Criação de semáforo para o arquivo ' + AllTrim(GA118ExtDirOrFileName(cXMLFile,2)) + '.')
	Else
		//1 de 2 pontos desta função em que o log é encerrado e retorna sem continuar até o fim da função.
		GFELog118:Add(GFENOW(.F.,,,':','.') + ' - Arquivo ' + AllTrim(GA118ExtDirOrFileName(cXMLFile,2)) + ' já está sendo importado.')
		GFELog118:EndLog()
		lContinua  := .F.
	EndIf
	If lContinua
		//Inclusa esta verificação pois há casos, quando processado via schedule/ComXCol, em que duas threads importam
		//o mesmo arquivo com uma pequena diferença de tempo. Mesmo após a primeira gravar o registro e remover o
		//semáforo, a segunda cria o semáforo mas não enxerga o registro na tabela GXG criado pela primeira.
		//Assim, optou-se por criar mais um controle por variável global e atraso de processamento. Somente após
		//determinado tempo um arquivo importado poderá ser importado novamente.

		ClearGlbValue('GFEA118*', 10) //Limpa todas as variáveis criadas por esta rotina que foram acessadas pela última vez há mais de 10s.

		cLockTime := GetGlbValue(cLock)
		If Vazio(cLockTime) .Or. Val(GFENow(.T.,,'','','')) - Val(cLockTime) > 3000
			PutGlbValue(cLock, GFENow(.T.,,'','',''))
			GFELog118:Add(GFENOW(.F.,,,':','.') + ' - Criação de variável de controle de importação para ' + AllTrim(GA118ExtDirOrFileName(cXMLFile,2)) + '.')
		Else
			//2 de 2 pontos desta função em que o log é encerrado e retorna sem continuar até o fim da função.
			GFELog118:Add(GFENOW(.F.,,,':','.') + ' - Arquivo ' + AllTrim(GA118ExtDirOrFileName(cXMLFile,2)) + ' em processo de importação.')
			GFELog118:EndLog()
			UnLockByName(cLock, .F., .F.) //Tira o lock caso contrário numa possível importação posterior ocasionará trava indevida pelo semáforo.
			lContinua := .F.
			lRetFuncao := .F.
		EndIf
		
		If lContinua
			GFELog118:Add(GFENOW(.F.,,,':','.') + SB2 + ' - Início da importação do arquivo.')
			If ExistBlock("GFEA1183")
				// quando retornar .F. o processo deve ser abortado.
				lRetFuncao := ExecBlock("GFEA1183",.F.,.F.,{oCTE})
				If !lRetFuncao
					GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Processo cancelado por chamada específica GFEA1183. Arquivo não importado.')
					lProcArq := .F.
				EndIf
			EndIf

			//Se for Evento de transporte, desvia para o tratamento
			//Atualmente é tratado somente o tipo evento de cancelamento
			If lProcArq
				If ValType(XmlChildEx(oCTe,"_EVENTOCTE")) == "O"
					nTipoXML := 3 //Arquivo de evento de cancelamento

					If !ValidSIX("GXG","5") .Or. !ValidSIX("GW3","E")
						If !IsBlind()
							MsgInfo("Para efetuar o cancelamento do CT-e, faz-se necessário aplicação do Update U_GFE11I37")
						EndIf

						GFELog118:Add(GFENOW(.F.,,,':','.') + ' - Falta aplicação do Update U_GFE11I37. Arquivo não importado.')
						lProcArq := .F.
						lMoveArq := .F.
					EndIf

					If lProcArq
						lRetFuncao := GFEA118ANU(cXMLFile,aProc,@cMsgPreVal, oCTE, lTotvsColab,XmlValid(oCTE,{"_EVENTOCTE","_INFEVENTO"},"_TPEVENTO"))[3]
						lProcArq := .F.
					EndIf
				EndIf
			EndIf

			If lProcArq
				cTpCte  := XmlValid(oCTE,{"_INFCTE","_IDE"},"_TPCTE")
				cTpServ := XmlValid(oCTE,{"_INFCTE","_IDE"},"_TPSERV")

				If ValType(oProtCte) == "O" .And. XmlChildEx(oProtCte:_INFPROT,"_CSTAT") != Nil
					cStat := XmlValid(oProtCte,{"_INFPROT"},"_CSTAT")
					//Busca status
					nPos  := aScan(aExcStat,AllTrim(oProtCte:_infProt:_cStat:Text))

					cChaveCte := SubStr(oCTe:_INFCTE:_ID:TEXT,4,44)
					
					If cTpCte == '3' //Grava chave CT-e substituição
						cChaveCteSub := XmlValid(oCTE,{"_INFCTE","_INFCTENORM","_INFCTESUB"},"_CHCTE")
					EndIf 

					//Status de cancelado ou rejeitado
					If nPos == 0

						//Motivo rejeição
						If Valtype(XmlChildEx(oProtCte:_infProt,"_XMOTIVO")) <> "U"
							cMotivo := XmlValid(oProtCte,{"_INFPROT"},"_XMOTIVO")
						Endif
						If cStat == "101" //Cancelado
							cMsgPreVal += "- " + "COM036 - CT-e cancelado: " + cChaveCte + CRLF
							aAdd(aErros,{cXMLFile,"COM036 - CT-e cancelado: " + cChaveCte,""})
							aAdd(aErroErp,{cXMLFile,"COM036"})

							If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
								cEmiProc := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"),@cMsgPreVal)
							Else
								cEmiProc := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF"),@cMsgPreVal)
							EndIf

							aGXG[37] := '5'
							lProtInv := .F.
						Else //Rejeitado
							cMsgPreVal += "- " + "COM037 - CT-e rejeitado: " + cChaveCte + " - Motivo: " + cMotivo + CRLF
							aAdd(aErros,{cXMLFile,"COM037 - CT-e rejeitado: " + cChaveCte + " - Motivo: " + cMotivo,""})
							aAdd(aErroErp,{cXMLFile,"COM037"})

							If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
								cEmiProc := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"),@cMsgPreVal)
							Else
								cEmiProc := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF"),@cMsgPreVal)
							EndIf

							aGXG[37] := '5'
							lProtInv := .F.
						Endif
					EndIf
				EndIf

				If XmlChildEx(oCTE:_INFCTE,"_COMPL") != Nil .And. XmlChildEx(oCTE:_INFCTE:_COMPL,"_XOBS") != Nil
					cObs := XmlValid(oCTE,{"_INFCTE","_COMPL"},"_XOBS")
				EndIf

				// Se for Ct-e de anulação ou substituição, desvia para o tratamento de anulação/substituição
				If cTpCte != Nil .And. cTpCte $ '2;3' .Or. (cTpCte == '0' .And. cStat == '101')
					nTipoXML := 2 //Arquivo de CTe de anulação/substituição

					If !ValidSIX("GXG","5") .Or. !ValidSIX("GW3","E")
						If !IsBlind()
							MsgInfo("Para efetuar a anulação/substituição do CT-e, faz-se necessário aplicação do Update U_GFE11I37")
						EndIf

						lProcArq   := .F.
						lMoveArq   := .F.
						lRetFuncao := .F.
					EndIf

					If lProcArq
						aOriDoc := GFEA118ANU(cXMLFile,aProc,@cMsgPreVal, oCTE, lTotvsColab,cTpCte,cStat)
						If cTpCte == '2' .Or. (cTpCte == '0' .And. cStat == '101')
							lProcArq   := .F.
							lRetFuncao := aOriDoc[3]
						EndIf
					EndIf
				EndIf
			EndIf

			If lProcArq
				nTipoXML := 1 //Arquivo de CTe normal

				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Início da validação do conteúdo do arquivo.')

				// Tag _INFCTENORM não existe em arquivos Ct-e de copmlemento de valores e anulação de valores
				If cTpCte $ "0;3"
					oInfDoc := XmlChildEx(oCTe:_INFCTE:_INFCTENORM, "_INFDOC")
					If (oInfDoc != nil)
						oInfNFE    := oCTe:_INFCTE:_INFCTENORM:_INFDOC
						oInfNF     := oCTe:_INFCTE:_INFCTENORM:_INFDOC
						oinfOutros := oCTe:_INFCTE:_INFCTENORM:_INFDOC
						// Valida se há pelo menos uma chave de CTe ou documento informado para processamento
						If !ValChaveDoc(oCTe:_INFCTE:_INFCTENORM:_INFDOC)
							cMsgPreVal += "- A chave do CTe (tag _CHAVE) ou número do documento (tag _NDOC) na tag _INFDOC não foram informados."+CRLF
						EndIf
					Else
						// Redespacho Intermediário e Serviço Multimodal

						If cTpServ $ "3;4"
							oDocAnt := XmlChildEx(oCTe:_INFCTE:_INFCTENORM, "_DOCANT")
							If (oDocAnt != nil)
								oCTeAnt := oCTe:_INFCTE:_INFCTENORM:_DOCANT
							Else
								oDocAnt := XmlChildEx(oCTe:_INFCTE:_INFCTENORM, "_INFSERVVINC")
								If (oDocAnt != nil)
									oCTeAnt := oCTe:_INFCTE:_INFCTENORM:_INFSERVVINC
								Else
									cMsgPreVal += "- O arquivo CT-e (Chave: " + cChaveCte + ") importado não é válido."+CRLF
									cMsgPreVal += "- A tag _DOCANT oU _INFSERVVINC não foi encontrada logo não é possivel relacionar o Documento de Carga."+CRLF	
								EndIF							
							Endif
						Else
							cMsgPreVal += "- O arquivo CT-e (Chave: " + cChaveCte + ") importado não é válido."+CRLF
							cMsgPreVal += "- A tag _INFDOC não foi encontrada."+CRLF
						EndIf
					EndIf
				EndIf
				aVldNF  := {"_INFCTE","_INFCTENORM","_INFDOC","_INFNF"}

				If lProcArq
					aGXG[2] :=  SuperGetMv('MV_ESPDF3', .F., '')//GXG->GXG_CDESP - (Especie de Documento)

					//Validação de Emissor
					If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
						cEmi := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"),@cMsgPreVal)
					Else
						cEmi := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF"),@cMsgPreVal)
					EndIf

					If Empty(cEmi)
						aGXG[3] := ""
					Else
						aGXG[3] := cEmi  //GXG->GXG_EMISDF - (Emissor)

						// Atribui controle de emissão de CT-e, caso esteja não esteja configurado
						cAliasGU3 := GetNextAlias()
						BeginSql Alias cAliasGU3
							SELECT GU3.R_E_C_N_O_ RECNOGU3
							FROM %Table:GU3% GU3
							WHERE GU3.GU3_FILIAL = %xFilial:GU3%
							AND GU3.GU3_CDEMIT = %Exp:cEmi%
							AND GU3.GU3_TRANSP = '1'
							AND GU3.GU3_CTE = '2'
							AND GU3.%NotDel%
						EndSql 
						If (cAliasGU3)->(!Eof())
							GU3->(dbGoTo((cAliasGU3)->RECNOGU3))
							RecLock('GU3',.F.)
								GU3->GU3_CTE := '1'
							GU3->(MsUnLock())
						EndIf
						(cAliasGU3)->(dbCloseArea())
					EndIf

					aGXG[4] :=  XmlValid(oCTe,{"_INFCTE","_IDE"},"_SERIE") //GXG->GXG_SERDF - (Serie)
					aGXG[5] :=  XmlValid(oCTe,{"_INFCTE","_IDE"},"_NCT")   //GXG->GXG_NRDF  - (Numero do Conhecimento)

					//Nesse ponto será inclusa verificação de registro já existente nas tabelas GXG.
					//Isso para os casos de execução via schedule, em que o COLAUTOREAD lê o arquivo, grava na
					//tabela CKO e exclui o arquivo. Depois, em outro processo, o COMXCOL processa esse registro.
					//Com isso, o controle transacional que antes era feito verificando a existência do arquivo
					//não pode mais ser feito dessa forma.
					//Assim, para evitar a inclusão de registros repetidos, será feita uma busca na tabela
					//antes da inclusão.
					//Mesmo com a inclusão do semáforo, será mantida a busca pela chave.
					aGXG[33] := SubStr(oCTe:_INFCTE:_ID:TEXT,4,44) //GXG->GXG_CTE
					
					If cTpCte == '3' //Grava chave CT-e substituição
						aGXG[40] := XmlValid(oCTE,{"_INFCTE","_INFCTENORM","_INFCTESUB"},"_CHCTE") //GXG->GXG_CTESUB
					EndIf 

					cAliasGXG := GetNextAlias()
					BeginSql Alias cAliasGXG
						SELECT GXG.GXG_ORIGEM,
								GXG.GXG_NRIMP,
								GXG.GXG_CTE
						FROM %Table:GXG% GXG
						WHERE GXG.GXG_CTE = %Exp:aGXG[33]%
						AND GXG.%NotDel%
					EndSql
					If (cAliasGXG)->(!Eof())
						If (cAliasGXG)->GXG_ORIGEM == "2"
							GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Conhecimento com a chave "' + (cAliasGXG)->GXG_CTE + '" já foi importado. Registro: ' + GXG->GXG_NRIMP + '.')
							GFELog118:Add(SB15 + SB6 + 'Arquivo não será importado.')
							aAdd(aErros,{cXMLFile, 'Conhecimento com a chave "' + (cAliasGXG)->GXG_CTE + '" já foi importado. Registro: ' + GXG->GXG_NRIMP + '. Arquivo não será importado.', ""})
							lImportaCte := .T.
						Else
							GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Conhecimento com a chave "' + (cAliasGXG)->GXG_CTE + '" já foi importado via EDI através do programa "Importar Conemb". Registro: ' + GXG->GXG_NRIMP + '.')
							GFELog118:Add(SB15 + SB6 + 'Arquivo não será importado.')
							aAdd(aErros,{cXMLFile, 'Conhecimento com a chave "' + (cAliasGXG)->GXG_CTE + '" já foi importado via EDI através do programa "Importar Conemb". Registro: ' + GXG->GXG_NRIMP + '. Arquivo não será importado.', ""})
							lImportaCte := .T.
						EndIf
					Else
						//(Data da Emissão) - Formato CTe AAAA-MM-DDTHH:MM:DD
						dDtEmis := StoD(SUBSTRING(XmlValid(oCTe,{"_INFCTE","_IDE"},"_DHEMI"),1,4) + ;
										SUBSTRING(XmlValid(oCTe,{"_INFCTE","_IDE"},"_DHEMI"),6,2) + ;
										SUBSTRING(XmlValid(oCTe,{"_INFCTE","_IDE"},"_DHEMI"),9,2) )
						aGXG[6] := dDtEmis	//GXG->GXG_DTEMIS

						//Validação do Remetente e Destinatário
						If XmlValid(oCTe,{"_INFCTE","_REM","_CNPJ"},"TEXT",.T.) == 'CNPJ'
							cAliasGU3 := GetNextAlias()
							BeginSql Alias cAliasGU3
								SELECT GU3.GU3_CDEMIT
								FROM %Table:GU3% GU3
								WHERE GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_IDFED = %Exp:XmlValid(oCTe,{"_INFCTE","_REM"}, "_CNPJ")%
								AND GU3.GU3_SIT = '1'
								AND GU3.%NotDel%
							EndSql
							aGXG[7] := (cAliasGU3)->GU3_CDEMIT
							(cAliasGU3)->(dbCloseArea())
							If Empty(aGXG[7])
								cMsgPreVal += "- Remetente não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_REM"}, "_CNPJ") + " no cadastro de emitentes." + CRLF
							EndIf
						ElseIf XmlValid(oCTe,{"_INFCTE","_REM","_CPF"},"TEXT",.T.) == 'CPF'
							cAliasGU3 := GetNextAlias()
							BeginSql Alias cAliasGU3
								SELECT GU3.GU3_CDEMIT
								FROM %Table:GU3% GU3
								WHERE GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_IDFED = %Exp:XmlValid(oCTe,{"_INFCTE","_REM"}, "_CPF")%
								AND GU3.GU3_SIT = '1'
								AND GU3.%NotDel%
							EndSql
							aGXG[7] := (cAliasGU3)->GU3_CDEMIT
							(cAliasGU3)->(dbCloseArea())
							If Empty(aGXG[7])
								cMsgPreVal += "- Remetente não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_REM"}, "_CPF") + " no cadastro de emitentes." + CRLF
							EndIf
						ElseIf !cTpServ $ "3;4"  //Redespacho Intermediario/Serv.Multimodal não precisa desta TAG
							cMsgPreVal += "- A Tag _REM não foi encontrada no CT-e com a chave: " + aGXG[33] + CRLF
						EndIf

						If XmlValid(oCTe,{"_INFCTE","_DEST","_CNPJ"},"TEXT",.T.)== 'CNPJ'
							cAliasGU3 := GetNextAlias()
							BeginSql Alias cAliasGU3
								SELECT GU3.GU3_CDEMIT
								FROM %Table:GU3% GU3
								WHERE GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_IDFED = %Exp:XmlValid(oCTe,{"_INFCTE","_DEST"},"_CNPJ")%
								AND GU3.GU3_SIT = '1'
								AND GU3.%NotDel%
							EndSql
							aGXG[8] := (cAliasGU3)->GU3_CDEMIT
							(cAliasGU3)->(dbCloseArea())
							If Empty(aGXG[8])
								cMsgPreVal += "- Destinatário não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_DEST"},"_CNPJ") + " no cadastro de emitentes." + CRLF
							EndIf
						Elseif XmlValid(oCTe,{"_INFCTE","_DEST","_CPF"},"TEXT",.T.)== 'CPF'
							cAliasGU3 := GetNextAlias()
							BeginSql Alias cAliasGU3
								SELECT GU3.GU3_CDEMIT
								FROM %Table:GU3% GU3
								WHERE GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_IDFED = %Exp:XmlValid(oCTe,{"_INFCTE","_DEST"},"_CPF")%
								AND GU3.GU3_SIT = '1'
								AND GU3.%NotDel%
							EndSql
							aGXG[8] := (cAliasGU3)->GU3_CDEMIT
							(cAliasGU3)->(dbCloseArea())
							If Empty(aGXG[8])
								cMsgPreVal += "- Destinatário não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_DEST"},"_CPF") + " no cadastro de emitentes." + CRLF
							EndIf
						ElseIf !cTpServ $ "3;4"   //Redespacho Intermediario/Serv.Multimodal não precisa desta TAG
							cMsgPreVal += "- A Tag _DEST não foi encontrada no CT-e com a chave: " + aGXG[33] + CRLF
						EndIf

						If cMV_GFEVPRT == '1'
							//- Verificar a existência da tag nProt. Caso não exista, gravar mensagem: "Não foi encontrado protocolo de autorização."
							If Valtype(oProtCte) != "O"
								cMsgPreVal += "- O parâmetro 'Valida protocolo/assinatura do CTe? (MV_GFEVPRT)' está como 1 - Sim e não foi encontrado protocolo de autorização (tag _NPROT) no CT-e com chave: " + aGXG[33] + CRLF
								aGXG[37] := '5'
							Else
								//  - Verificar a existência da tag DigestValue. Caso não exista, gravar mensagem: "Não foi encontrado chave de assinatura digital (DigestValue).";
								If XmlValid(oCTe,{"_SIGNATURE","_SIGNEDINFO","_REFERENCE"},"_DIGESTVALUE",.F.) == '' .Or. XmlValid(oCTe,{"_SIGNATURE","_SIGNEDINFO","_REFERENCE"},"_DIGESTVALUE",.F.) == Nil
									cMsgPreVal += "- O parâmetro 'Valida protocolo/assinatura do CTe? (MV_GFEVPRT)' está como 1 - Sim e não foi encontrado chave de assinatura digital (tag _DIGESTVALUE) no CT-e com chave: " + aGXG[33] + CRLF
									aGXG[37] := '5'
									lProtInv := .F.
								EndIf

								//  - Verificar a existência da tag digVal. Caso não exista, gravar mensagem: "Não foi encontrado chave de assinatura digital (digVal).";
								If XmlChildEx(oProtCte:_INFPROT,"_DIGVAL") == Nil
									cMsgPreVal += "- O parâmetro 'Valida protocolo/assinatura do CTe? (MV_GFEVPRT)' está como 1 - Sim e não foi encontrado chave de assinatura digital (tag _DIGVAL) no CT-e com chave: " + aGXG[33] + CRLF
									aGXG[37] := '5'
									lProtInv := .F.
								EndIf

								//  - Se ambas existirem, e forem diferentes gravar a mensagem
								If lProtInv
									If XmlValid(oCTe,{"_SIGNATURE","_SIGNEDINFO","_REFERENCE"},"_DIGESTVALUE",.F.) != XmlValid(oProtCte,{"_INFPROT"},"_DIGVAL",.F.)
										cMsgPreVal += "- O parâmetro 'Valida protocolo/assinatura do CTe? (MV_GFEVPRT)' está como 1 - Sim e as chaves de assinatura digital (tag _DIGESTVALUE) e (tag _DIGVAL) não podem ser diferentes no CT-e com chave: " + aGXG[33] + CRLF
										aGXG[37] := '5'
									EndIf
								EndIf
							EndIf
						EndIf

						// Além das regras padrão para tornar um CT-e com Erro Impeditivo, permitir que o cliente desenvolva regras, independente do parâmetro.
						If ExistBlock("GFEA1185")
							lRetEdiSit := ExecBlock("GFEA1185",.F.,.F.,{oCTE, oProtCte})

							If !lRetEdiSit
								cMsgPreVal += "- " + "Atribuída situação 'Erro Impeditivo' por chamada específica do GFEA1185." + CRLF
								GFELog118:Add(GFENOW(.F.,,,':','.') + " - Atribuída situação 'Erro Impeditivo' por chamada específica do GFEA1185.")
								aGXG[37] := '5'
							EndIf
						EndIf

						aGXG[10] := dDatabase //GXG->GXG_DTENT - (Data de entrada)Data atual
						aGXG[11] := ''        //GXG->GXG_CDCONS - Deixar em branco

						cAliasGU3 := GetNextAlias()
						BeginSql Alias cAliasGU3
							SELECT 1
							FROM %Table:GU3% GU3
							WHERE GU3.GU3_FILIAL = %xFilial:GU3%
							AND GU3.GU3_CDEMIT = %Exp:cEmi%
							AND GU3.GU3_APUICM = '4'
							AND GU3.GU3_SIT = '1'
							AND GU3.%NotDel%
						EndSql
						lApuIcm := (cAliasGU3)->(!Eof())
						(cAliasGU3)->(dbCloseArea())
						//Tipo de Tributacao
						//1=Tributado;2=Isento/Não-tributado;3=Subs Tributária;4=Diferido;5=Reduzido;6=Outros;7=Presumido
						If XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},'',.T.) == 'ICMS00' ;
							.Or. XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS20"},'',.T.) == 'ICMS20' //Tributado

							aGXG[13] := '1' //GXG->GXG_TRBIMP - Tipo de Tributacao

							If XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},'',.T.) == 'ICMS00'
								aGXG[14] :=	 XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},"_VICMS")//GXG->GXG_VLIMP - Valor do Imposto
								aGXG[15] :=  XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},"_VBC")     //GXG->GXG_BASIMP - Base de Calculo Imposto
								aGXG[16] :=  XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},"_PICMS")   //GXG->GXG_PCIMP - Aliquota do Imposto
							Else
								aGXG[14] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS20"},"_VICMS") //GXG->GXG_VLIMP - Valor do Imposto
								aGXG[15] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS20"},"_VBC")   //GXG->GXG_BASIMP - Base de Calculo Imposto
								aGXG[16] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS20"},"_PICMS") //GXG->GXG_PCIMP - Aliquota do Imposto
							EndIf
						ElseIf XmlValid(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMS40"} , '' , .T. ) == 'ICMS40' ;//Isento/Não Tributado
							.Or. XmlValid(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMS41"} , '' , .T. ) == 'ICMS41' ;
							.Or. XmlValid(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMS45"} , '' , .T. ) == 'ICMS45'

							If XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS45"},"_CST") == '51'    //Diferido
								aGXG[13] := '4' 	//GXG->GXG_TRBIMP - Tipo de Tributacao
								aGXG[14] := "0.00"
								aGXG[15] := "0.00"
								aGXG[16] := "0.00"
							Else
								aGXG[13] := '2' 	//GXG->GXG_TRBIMP - Tipo de Tributacao
							EndIf
						ElseIf  XmlValid(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMSSN"} , '' , .T. ) == 'ICMSSN'  //Simples Nacional
							aGXG[13] := '6' 	//GXG->GXG_TRBIMP - Tipo de Tributacao
							aGXG[15] := XmlValid(oCTe,{"_INFCTE","_VPREST"},"_VTPREST")
						ElseIf  XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},'',.T.) == 'ICMS60' .And. lApuIcm   //Subst. Tributaria e apuração do ICMS por parte do emitente do documento de frete igual a presumido
							aGXG[13] := '7' 	//GXG->GXG_TRBIMP - Tipo de Tributacao
							aGXG[14] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vICMSSTRet") //GXG->GXG_VLIMP - Valor do Imposto
							aGXG[15] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vBCSTRet")   //GXG->GXG_BASIMP - Base de Calculo Imposto
							aGXG[16] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_pICMSSTRet") //GXG->GXG_PCIMP - Aliquota do Imposto
						ElseIf  XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},'',.T.) == 'ICMS60'   //Subst. Tributaria
							aGXG[13] := '3' 	//GXG->GXG_TRBIMP - Tipo de Tributacao
							aGXG[14] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vICMSSTRet") //GXG->GXG_VLIMP - Valor do Imposto
							aGXG[15] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vBCSTRet")   //GXG->GXG_BASIMP - Base de Calculo Imposto
							aGXG[16] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_pICMSSTRet") //GXG->GXG_PCIMP - Aliquota do Imposto
						ElseIf XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},'',.T.) == 'ICMS90' //Outros
							aGXG[13] := '6' //GXG->GXG_TRBIMP - Tipo de Tributacao
							aGXG[14] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},"_VICMS")  //GXG->GXG_VLIMP - Valor do Imposto
							aGXG[15] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},"_VBC")    //GXG->GXG_BASIMP - Base de Calculo Imposto
							aGXG[16] := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},"_PICMS")  //GXG->GXG_PCIMP - Aliquota do Imposto
						ElseIf XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},'',.T.) == 'ICMSOutraUF'
							aGXG[13] := '1'  //GXG->GXG_TRBIMP - Tipo de Tributacao
							aGXG[14] := XmlValid(oCte,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},"_vICMSOutraUF",.F.) //GXG->GXG_VLIMP - Valor do Imposto
							aGXG[15] := XmlValid(oCte,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},"_vBCOutraUF",  .F.) //GXG->GXG_BASIMP - Base de Calculo Imposto
							aGXG[16] := XmlValid(oCte,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},"_pICMSOutraUF",.F.) //GXG->GXG_PCIMP - Aliquota do Imposto

							If aGXG[14] == '0.00'
								aGXG[13] := '6'  //Quando o valor do imposto for zerado, não pode ser Tributado
							EndIf
						EndIf

						//Subst Tribuária, Presumido - quando os valores não vem no XML
						If (aGXG[16] == '0.00' .Or. aGXG[16] = '0' .Or. aGXG[15] == "0.00" .OR. aGXG[15] == "0" .Or. aGXG[14] == "0.00" .OR. aGXG[14] == "0") .AND. ( aGXG[13] == '3' .OR. aGXG[13] == '7')
						    codCidIni  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunIni")
							codCidFim  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunFim")
							aRetICMS   := GFEFnIcms(aGXG[03],;      // Código do transportador
													aGXG[07],;      // Código do remetente
													aGXG[08],;      // Código do destinatario
													codCidIni,;     // Número da cidade de origem
													codCidFim,;     // Número da cidade de destino
													"0", ;          // Forma de utilização da mercadoria
													"0", ;          // Tipo de item
													"0", ;          // Classificação de frete
													"1", ;          // Mercadoria é tributada de ICMS?
													"0",;           //Tipo de Operação do Agrupador do Documento de Carga
													xFilial("GXG")) // Filial do cálculo - Usado no parâmetro MV_GFECRIC para as exceções das filiais que não tem direito a crédito

							aGXG[16] := (Transform((aRetICMS[1]), '@R 99.99'))  // Retorno do valor do percentual de ICMS
							If aGXG[15] == "0.00" .OR. aGXG[15] == "0"
								aGXG[15] := XmlValid(oCTe,{"_INFCTE","_VPREST"},"_VTPREST")
							EndIf

							If aGXG[14] == "0.00" .OR. aGXG[14] == "0"
								aGXG[14] := CValToChar(VAL(aGXG[15]) * VAL(aGXG[16]) / 100)
							EndIf
						Endif

						lFindGW1 := .F.
						//Tratamento para transformar a tag de NF em um array, validando se é NF ou NFe, Outros, Redespacho Intermediário ou Doc Complementar
						If !Empty(oInfNF) .And. ValType(XmlChildEx(oInfNF,"_INFNF")) $ "O/A"

							xMotivo := XmlValid(oCTe,{"_INFDOC","_INFOUTROS"}, "_NDOC")
							//Verifica as informações da nota vinculada

							If (!(XmlValid(oCTe,{"_INFDOC"}, "_INFOUTROS") == NIL) .And. xMotivo == NIL)
								cMsgPreVal += "- Para nota complementar verifique a (Tag _NDOC) no CT-e Importado." + CRLF
							ElseIf ValType(XmlChildEx(oInfNF,"_INFNF")) == "O"
								XmlNode2Arr( oInfNF:_INFNF , "_INFNF" )
							EndIf

							aNF := oInfNF:_INFNF

							aGXG[18]  := XmlValid(oCTe,aVldNF,"_NPESO") //GXG->GXG_PESOR - Peso Real
							nFCont := Len(aNF)
							For nCont := 1 To nFCont
								If XmlValid(oCTe,{"_INFCTE","_REM","_CNPJ"},"TEXT",.T.)== 'CNPJ'
									cCgcRem := XmlValid(oCTe,{"_INFCTE","_REM"}, "_CNPJ")
								Else
									cCgcRem := XmlValid(oCTe,{"_INFCTE","_REM"}, "_CPF")
								EndIf

								If XmlValid(oCTe,{"_INFCTE","_DEST","_CNPJ"},"TEXT",.T.)== 'CNPJ'
									cCgcDest := XmlValid(oCTe,{"_INFCTE","_DEST"}, "_CNPJ")
								Else
									cCgcDest := XmlValid(oCTe,{"_INFCTE","_DEST"},"_CPF")
								EndIf

								cAliasGU3 := GetNextAlias()
								BeginSql Alias cAliasGU3
									SELECT GU3.GU3_CDEMIT
									FROM %Table:GU3% GU3
									WHERE GU3.GU3_FILIAL = %xFilial:GU3%
									AND GU3.GU3_IDFED = %Exp:cCgcRem%
									AND GU3.GU3_SIT = '1'
									AND GU3.%NotDel%
								EndSql
								If (cAliasGU3)->(!Eof())
									cDoc   := Replicate("0",nCountZerosNF) + aNF[nCont]:_NDOC:TEXT
									cSerie := PADR(Alltrim(aNF[nCont]:_SERIE:TEXT) , TamSX3("GXH_SERDC")[1],'')

									If lTotvsColab
										If !ValidCFOP( cDoc,;      //cDoc
														cSerie,;   //cSerie
														cCgcRem,;  //cCliFor
														cCgcDest,; //cCgcDest
														"" )       //NFE

											//Se a Faixa do CFOP NÃO Estiver como integra GFE
											//ou se Não Listado NÃO Estiver como Integra GFE então Retorna para integrar no ImpXML_CTe
											GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - (COMXCOL) CFOP do documento de carga configurado para não integrar com GFE.')
											// Inicializa a variavel de controle porque será processado por compras
											cMsgPreVal := ""
											lComxcol   := .T.
											lProcArq   := .F.
											Exit
										EndIf
									EndIf

									lNrDf := .F.

									Do While (cAliasGU3)->(!Eof())
										cNumDC := CValToChar(val( aNF[nCont]:_NDOC:TEXT))
										nCountZerosNF := 0
										// Busca o Documento de Carga do CT-e
										// Se não encontrar, tenta procurar documentos com zeros a esquerda
										Do While nCountZerosNF <= 6
											cNumeroNF := Replicate("0",nCountZerosNF) + cNumDC
											If BuscaDocTrechoPago("", (cAliasGU3)->GU3_CDEMIT, Upper(Alltrim(aNF[nCont]:_SERIE:TEXT)), AllTrim(cNumeroNF),,,@nRecnoGW1)
												lFindGW1 := .T.

												cAliasGW1 := GetNextAlias()
												BeginSql Alias cAliasGW1
													SELECT GW1.GW1_FILIAL,
															GW1.GW1_CDTPDC,
															GW1.GW1_EMISDC,
															GW1.GW1_SERDC,
															GW1.GW1_NRDC,
															GW1.GW1_CDREM,
															GW1.GW1_CDDEST,
															GW1.GW1_DANFE,
															GU3.GU3_IDFED
													FROM %Table:GW1% GW1
													INNER JOIN %Table:GU3% GU3
													ON GU3.GU3_FILIAL = %xFilial:GU3%
													AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
													AND GU3.GU3_SIT = '1'
													AND GU3.%NotDel%
													WHERE GW1.R_E_C_N_O_ = %Exp:nRecnoGW1%
													AND GW1.%NotDel%
												EndSql
												If (cAliasGW1)->(!Eof())
													aAdd(aGXH, {(cAliasGW1)->GW1_FILIAL,;
																Alltrim(STR(nCont)),;
																(cAliasGW1)->GW1_EMISDC, ;
																(cAliasGW1)->GW1_SERDC,;
																(cAliasGW1)->GW1_NRDC,;
																(cAliasGW1)->GW1_CDTPDC,;
																(cAliasGW1)->GW1_DANFE,;
																(cAliasGW1)->GU3_IDFED})

													cFilGW1  := (cAliasGW1)->GW1_FILIAL
													lNrDf := .T.
													Exit
												EndIf
												(cAliasGW1)->(dbCloseArea())
											EndIf
											nCountZerosNF++
										EndDo

										If Len(aGXH) > 0
											Exit
										EndIf
										(cAliasGU3)->(dbSkip())
									EndDo

									If !lNrDf
										aAdd(aGXH, {'',;
													Alltrim(STR(nCont)),;
													'', ;
													Alltrim(aNF[nCont]:_SERIE:TEXT),;
													cValToChar(Val(cNumeroNF)),;
													'',;
													'',;
													cCgcRem/*cnpj do emissor da nota.*/})

										cMsgPreVal += "- Não foi encontrado documento de carga com número " + aNF[1]:_NDOC:TEXT + " e série " + aNF[1]:_SERIE:TEXT + " ou foi encontrado um "
										cMsgPreVal += "ou mais de um documento de carga com mesmo número/série/emissor em filiais diferentes, todos com trecho não pago e transportador não informado. "
										cMsgPreVal += "Para mais detalhes ative o LOG e verifique as mensagens detalhadas." + CRLF
									EndIf
								EndIf
								(cAliasGU3)->(dbCloseArea())
							Next nCont
							nNF := Len(aNF)

						ElseIf !Empty(oInfOutros) .And. ValType(XmlChildEx(oInfOutros,"_INFOUTROS")) $ "O/A"
							//Verifica as informações da nota vinculada
							If ValType(XmlChildEx(oInfOutros,"_INFOUTROS")) == "O"
								XmlNode2Arr( oInfOutros:_INFOUTROS , "_INFOUTROS" )
							EndIf

							aNF := oInfOutros:_INFOUTROS
							aGXG[18]  := XmlValid(oCTe,aVldNF,"_NPESO") //GXG->GXG_PESOR - Peso Real
							nFCont := Len(aNF)
							For nCont := 1 To nFCont
								If XmlValid(oCTe,{"_INFCTE","_REM","_CNPJ"},"TEXT",.T.)== 'CNPJ'
									cCgcRem := XmlValid(oCTe,{"_INFCTE","_REM"}, "_CNPJ")
								Else
									cCgcRem := XmlValid(oCTe,{"_INFCTE","_REM"}, "_CPF")
								EndIf

								If XmlValid(oCTe,{"_INFCTE","_DEST","_CNPJ"},"TEXT",.T.)== 'CNPJ'
									cCgcDest := XmlValid(oCTe,{"_INFCTE","_DEST"}, "_CNPJ")
								Else
									cCgcDest := XmlValid(oCTe,{"_INFCTE","_DEST"},"_CPF")
								EndIf

								cAliasGU3 := GetNextAlias()
								BeginSql Alias cAliasGU3
									SELECT GU3.GU3_CDEMIT
									FROM %Table:GU3% GU3
									WHERE GU3.GU3_FILIAL = %xFilial:GU3%
									AND GU3.GU3_IDFED = %Exp:cCgcRem%
									AND GU3.GU3_SIT = '1'
									AND GU3.%NotDel%
								EndSql
								If (cAliasGU3)->(!Eof())
									If (XmlValid(oCTe,{"_INFDOC"}, "_INFOUTROS") # NIL .And. xMotivo == NIL) .And. !Empty(XmlValid(oinfOutros, {"_INFOUTROS"}, "_nDoc"))
										cDoc   := Replicate("0",nCountZerosNF) + aNF[nCont]:_NDOC:TEXT
										cSerie := ''
									EndIf
									If lTotvsColab
										If !ValidCFOP( cDoc,;      //cDoc
														cSerie,;   //cSerie
														cCgcRem,;  //cCliFor
														cCgcDest,; //cCgcDest
														'')        //NFE

											//Se a Faixa do CFOP NÃO Estiver como integra GFE
											//ou se Não Listado NÃO Estiver como Integra GFE então Retorna para integrar no ImpXML_CTe
											GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - (COMXCOL) CFOP do documento de carga configurado para não integrar com GFE.')
											// Inicializa a variavel de controle porque será processado por compras
											cMsgPreVal := ""
											lComxcol   := .T.
											lProcArq   := .F.
											Exit
										EndIf
									EndIf

									lNrDf := .F.

									Do While (cAliasGU3)->(!Eof())
										If !ValChaveDoc(oinfOutros) .And. xMotivo == NIL
											cNumeroNF := "0"
										Else
											cNumDC := CValToChar(val( aNF[nCont]:_NDOC:TEXT))
											nCountZerosNF := 0
											// Busca o Documento de Carga do CT-e
											// Se não encontrar, tenta procurar documentos com zeros a esquerda
											Do While nCountZerosNF <= 6
												cNumeroNF := Replicate("0",nCountZerosNF) + cNumDC

												cAliasGW1 := GetNextAlias()
												BeginSql Alias cAliasGW1
													SELECT GW1.GW1_FILIAL,
															GW1.GW1_EMISDC,
															GW1.GW1_SERDC,
															GW1.GW1_NRDC,
															GW1.GW1_CDTPDC,
															GW1.GW1_DANFE,
															GU3.GU3_IDFED
													FROM %Table:GW1% GW1
													INNER JOIN %Table:GU3% GU3
													ON GU3.GU3_FILIAL = %xFilial:GU3%
													AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
													AND GU3.GU3_IDFED = %Exp:cCgcRem%
													AND GU3.GU3_SIT = '1'
													AND GU3.%NotDel%
													WHERE GW1.GW1_FILIAL = %xFilial:GW1%
													AND GW1.GW1_NRDC = %Exp:cNumeroNF%
													AND GW1.%NotDel%
												EndSql
												If (cAliasGW1)->(!Eof())
													lFindGW1 := .T.

													aAdd(aGXH, {(cAliasGW1)->GW1_FILIAL,;
																Alltrim(STR(nCont)),;
																(cAliasGW1)->GW1_EMISDC, ;
																(cAliasGW1)->GW1_SERDC,;
																(cAliasGW1)->GW1_NRDC,;
																(cAliasGW1)->GW1_CDTPDC,;
																(cAliasGW1)->GW1_DANFE,;
																(cAliasGW1)->GU3_IDFED})

													lNrDf := .T.
													cFilGW1 := (cAliasGW1)->GW1_FILIAL
													Exit
												EndIf
												(cAliasGW1)->(dbCloseArea())
												nCountZerosNF++
											EndDo
											If Len(aGXH) > 0
												Exit
											EndIf
										EndIf
										(cAliasGU3)->(dbSkip())
									EndDo

									If !lNrDf .And. (XmlValid(oCTe,{"_INFDOC"}, "_INFOUTROS") # NIL .And. xMotivo == NIL)
										aAdd(aGXH, {"",;
													Alltrim(STR(nCont)),;
													"", ;
													"", ;
													cValToChar(Val(cNumeroNF)),;
													"",;
													"",;
													cCgcRem/*cnpj do emissor da nota.*/})

										cMsgPreVal += "- Não foi encontrado documento de carga com número " + iif(Val(cNumeroNF)==0,cNumeroNF,aNF[1]:_NDOC:TEXT) + " ou foi encontrado um "
										cMsgPreVal += "ou mais de um documento de carga com mesmo número/série/emissor em filiais diferentes, todos com trecho não pago e transportador não informado. "
										cMsgPreVal += "Para mais detalhes ative o LOG e verifique as mensagens detalhadas." + CRLF
									EndIf
								EndIf
								(cAliasGU3)->(dbCloseArea())
							Next nCont
							nNF := Len(aNF)

						ElseIf !Empty(oInfNFE) .And. ValType(XmlChildEx(oInfNFE,"_INFNFE")) $ "O/A"
							//Verifica as informações da nota vinculada
							If ValType(XmlChildEx(oInfNFE,"_INFNFE")) == "O"
								XmlNode2Arr( oInfNFE:_INFNFE  , "_INFNFE" )
							EndIf
							aNFe := oInfNFE:_INFNFE

							cDoc   := ""
							cSerie := ""

							If lTotvsColab
								If !ValidCFOP( cDoc,;                // cDoc
												cSerie,;             // cSerie
												'',;                 // cCliFor
												'',;                 // cCgcDest
												aNFe[1]:_CHAVE:TEXT) // Chave NFE
									//Se a Faixa do CFOP NÃO Estiver como integra GFE
									//ou se Não Listado NÃO Estiver como Integra GFE então Retorna para integrar no ImpXML_CTe
									GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - (COMXCOL) CFOP do documento de carga configurado para não integrar com GFE.')
									// Inicializa a variavel de controle porque será processado por compras
									cMsgPreVal := ""
									lComxcol   := .T.
									lProcArq   := .F.
								EndIf
							EndIf
							If lProcArq
								nFCont := Len(aNFe)
								For nCont := 1 To nFCont
									If BuscaDocTrechoPago(aNFe[nCont]:_CHAVE:TEXT,,,,,,@nRecnoGW1)
										lFindGW1 := .T.

										cAliasGW1 := GetNextAlias()
										BeginSql Alias cAliasGW1
											SELECT GW1.GW1_FILIAL,
													GW1.GW1_CDTPDC,
													GW1.GW1_EMISDC,
													GW1.GW1_SERDC,
													GW1.GW1_NRDC,
													GW1.GW1_CDREM,
													GW1.GW1_CDDEST,
													GW1.GW1_DANFE,
													GU3.GU3_IDFED
											FROM %Table:GW1% GW1
											INNER JOIN %Table:GU3% GU3
											ON GU3.GU3_FILIAL = %xFilial:GU3%
											AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
											AND GU3.GU3_SIT = '1'
											AND GU3.%NotDel%
											WHERE GW1.R_E_C_N_O_ = %Exp:nRecnoGW1%
											AND GW1.%NotDel%
										EndSql
										If (cAliasGW1)->(!Eof())
											aTemp := Array(8)
											aTemp[1] := (cAliasGW1)->GW1_FILIAL //GXH_FILIAL
											aTemp[2] := nCont           //GXH_SEQ
											aTemp[3] := (cAliasGW1)->GW1_EMISDC //GXH_EMISDC
											aTemp[4] := (cAliasGW1)->GW1_SERDC  //GXH_SERDC
											aTemp[5] := (cAliasGW1)->GW1_NRDC   //GXH_NRDC
											aTemp[6] := (cAliasGW1)->GW1_CDTPDC //GXH_TPDC
											aTemp[7] := (cAliasGW1)->GW1_DANFE  //GXH_TPDC
											aTemp[8] := (cAliasGW1)->GU3_IDFED

											aADD(aGXH, aTemp)

											cFilGW1  := (cAliasGW1)->GW1_FILIAL
										EndIf
										(cAliasGW1)->(dbCloseArea())
									Else
										cNFE := aNFe[nCont]:_CHAVE:TEXT
										cAliasGW1 := GetNextAlias()
										BeginSql Alias cAliasGW1
											SELECT GW1.GW1_FILIAL,
													GW1.R_E_C_N_O_ RECNOGW1
											FROM %Table:GW1% GW1
											WHERE GW1.GW1_DANFE =%Exp:cNFE%
											AND GW1.%NotDel%
										EndSql
										If (cAliasGW1)->(!Eof())
											cFilGW1  := (cAliasGW1)->GW1_FILIAL
											lFindGW1 := .T.
										EndIf
										(cAliasGW1)->(dbCloseArea())			

										aTemp    := Array(8)
										aTemp[7] := aNFe[nCont]:_CHAVE:TEXT
										AAdd(aGXH,aTemp)

										cMsgPreVal += "- Documento de carga não encontrado com a chave da NFe: " + aNFe[nCont]:_CHAVE:TEXT
										cMsgPreVal += " ou documento encontrado, porém com o trecho não pago. "
										cMsgPreVal += "Para mais detalhes ative o LOG e verifique as mensagens detalhadas." + CRLF
									EndIf
								Next nCont

								nNF := Len(aNFe)
							EndIf
						ElseIf !Empty(oDocAnt) 
							// Avalia se retorno do documentos anterior é uma lista

							IF ValType(XmlChildEx(oCTeAnt,"_EMIDOCANT")) $ "O/A"

								lArrayCTe  := ValType(XmlChildEx(oCTeAnt,"_EMIDOCANT")) == "A"
								nFCont := IIf(lArrayCTe, Len(oCTe:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT), 1)

								For nContId := 1 To nFCont
									If NfCont > 1
										lDocAntEle := ValType(XmlChildEx(oCTeAnt:_EMIDOCANT[nContId]:_IDDOCANT,"_IDDOCANTELE")) == "A"
										nDocAntEle := IIf(lDocAntEle, Len(oCTeAnt:_EMIDOCANT[nContId]:_IDDOCANT:_IDDOCANTELE), 0)
									Else
										lDocAntEle := ValType(XmlChildEx(oCTeAnt:_EMIDOCANT:_IDDOCANT,"_IDDOCANTELE")) == "A"
										nDocAntEle := IIf(lDocAntEle, Len(oCTeAnt:_EMIDOCANT:_IDDOCANT:_IDDOCANTELE), 0)
									EndIf		
									nFCont2 := IIf(lDocAntEle, nDocAntEle, 1)

									For nContId2 := 1 To nFCont2
									// Referente a conhecimento anterior - internacional e exportação - A princípio não foi utilizado
										If lArrayCte
											If NfCont > 1
												cChaveRel := oCTe:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT[nContId]:_IDDOCANT:_IDDOCANTELE:_CHCTE:TEXT
											Else
												cChaveRel := oCTe:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IDDOCANT:_IDDOCANTELE:_CHCTE:TEXT
											EndIf
										Else
											If lDocAntEle
												If nFCont2 > 1 .And. nFCont > 1
													cChaveRel := oCTeAnt:_EMIDOCANT[nContId]:_IDDOCANT:_IDDOCANTELE[nContId2]:_CHCTE:TEXT
												ElseIf nFCont2 > 1 .And. nFCont == 1
													cChaveRel := oCTeAnt:_EMIDOCANT:_IDDOCANT:_IDDOCANTELE[nContId2]:_CHCTE:TEXT
												ELseIf nFCont2 == 1 .And. nFCont > 1
													cChaveRel := oCTeAnt:_EMIDOCANT[nContId]:_IDDOCANT:_IDDOCANTELE:_CHCTE:TEXT
												Else 
													cChaveRel := oCTeAnt:_EMIDOCANT:_IDDOCANT:_IDDOCANTELE:_CHCTE:TEXT	
												EndIf	
											Else
												cChaveRel := XmlValid(oCTe,{"_INFCTE","_INFCTENORM","_DOCANT","_EMIDOCANT","_IDDOCANT","_IDDOCANTELE"},"_CHCTE")
											EndIf
										EndIf

										If !Empty(cChaveRel)

											aRetCte := GFE118CTE(cChaveRel)

											lFindGW1 := aRetCte[1]
											cFilGW1  := aRetCte[2]
											cMsgPreVal += aRetCte[3]
											
										Else
											cMsgPreVal += "- Documento de frete não encontrado, logo não é possivel relacionar o Documento de Carga. Chave documento anterior: " + cChaveRel + CRLF
										EndIf
									Next nContId2
								Next nContId

							ELSEIF ValType(XmlChildEx(oCTeAnt,"_INFCTEMULTIMODAL")) $ "O/A"

								lArrayCTe  := ValType(XmlChildEx(oCTeAnt,"_INFCTEMULTIMODAL")) == "A"
								nFCont := IIf(lArrayCTe, Len(oCTe:_INFCTE:_INFCTENORM:_INFSERVVINC:_INFCTEMULTIMODAL), 1)

								For nContId := 1 To nFCont

									If lArrayCte
										If NfCont > 1
											cChaveRel := oCTe:_INFCTE:_INFCTENORM:_INFSERVVINC:_INFCTEMULTIMODAL[nContId]:_CHCTEMULTIMODAL:TEXT
										EndIf
									Else
										cChaveRel := XmlValid(oCTe,{"_INFCTE","_INFCTENORM","_INFSERVVINC","_INFCTEMULTIMODAL"},"_CHCTEMULTIMODAL")
									EndIf

									If !Empty(cChaveRel)

										aRetCte := GFE118CTE(cChaveRel)

										lFindGW1 := aRetCte[1]
										cFilGW1  := aRetCte[2]
										cMsgPreVal += aRetCte[3]										

									Else
										cMsgPreVal += "- Documento de frete não encontrado, logo não é possivel relacionar o Documento de Carga. Chave documento anterior: " + cChaveRel + CRLF
									EndIf										

								Next nContId
							EndIF							
						Else
							//Verifica se o tipo do CTe for complementar
							If cTpCte == "1"
								cChaveRel := XmlValid(oCTe,{'_INFCTE','_INFCTECOMP'},'_CHCTE')
								//Ler o DC a partir do conhecimento normal.
								cAliasGW3 := GetNextAlias()
								BeginSql Alias cAliasGW3
									SELECT GW3.GW3_SERDF,
											GW3.GW3_NRDF,
											GW1.GW1_FILIAL
									FROM %Table:GW3% GW3
									INNER JOIN %Table:GW4% GW4
									ON GW4.GW4_FILIAL = GW3.GW3_FILIAL
									AND GW4.GW4_EMISDF = GW3.GW3_EMISDF
									AND GW4.GW4_CDESP = GW3.GW3_CDESP
									AND GW4.GW4_SERDF = GW3.GW3_SERDF
									AND GW4.GW4_NRDF = GW3.GW3_NRDF
									AND GW4.%NotDel%
									INNER JOIN %Table:GW1% GW1
									ON GW1.GW1_FILIAL = GW4.GW4_FILIAL
									AND GW1.GW1_CDTPDC = GW4.GW4_TPDC
									AND GW1.GW1_EMISDC = GW4.GW4_EMISDC
									AND GW1.GW1_SERDC = GW4.GW4_SERDC
									AND GW1.GW1_NRDC = GW4.GW4_NRDC
									AND GW1.%NotDel%
									WHERE GW3.GW3_CTE = %Exp:cChaveRel%
									AND GW3.%NotDel%
								EndSql
								If (cAliasGW3)->(!Eof())
									aOriDoc[1] := (cAliasGW3)->GW3_SERDF
									aOriDoc[2] := (cAliasGW3)->GW3_NRDF
									aOriDoc[3] := .T.

									cFilGW1  := (cAliasGW3)->GW1_FILIAL
									lFindGW1 := .T.
								Else
									// Se não encontrar nos documentos de frete busca na GXG
									If Len(aGXH) == 0 .And. ValidSIX("GXG", "5")
										cAliasGXG1 := GetNextAlias()
										BeginSql Alias cAliasGXG1
											SELECT GXG.GXG_FILIAL,
													GXG.GXG_NRIMP,
													GXG.GXG_SERDF,
													GXG.GXG_NRDF,
													GW1.GW1_FILIAL
											FROM %Table:GXG% GXG
											INNER JOIN %Table:GXH% GXH
											ON GXH.GXH_FILIAL = GXG.GXG_FILIAL
											AND GXH.GXH_NRIMP = GXG.GXG_NRIMP
											AND GXH.%NotDel%
											INNER JOIN %Table:GW1% GW1
											ON GW1.GW1_FILIAL = GXH.GXH_FILDC
											AND GW1.GW1_CDTPDC = GXH.GXH_TPDC
											AND GW1.GW1_EMISDC = GXH.GXH_EMISDC
											AND GW1.GW1_SERDC = GXH.GXH_SERDC
											AND GW1.GW1_NRDC = GXH.GXH_NRDC
											AND GW1.%NotDel%
											WHERE GXG.GXG_CTE = %Exp:cChaveRel%
											AND GXG.%NotDel%
										EndSql
										If (cAliasGXG1)->(!Eof())
											aOriDoc[1] := (cAliasGXG1)->GXG_SERDF
											aOriDoc[2] := (cAliasGXG1)->GXG_NRDF
											aOriDoc[3] := .T.

											cFilGW1  := (cAliasGXG1)->GW1_FILIAL
											lFindGW1 := .T.
										EndIf
										(cAliasGXG1)->(dbCloseArea())
									EndIf
								EndIf
								(cAliasGW3)->(dbCloseArea())
							EndIf
						EndIf
						If lProcArq
							// Regra de preenchimento da filial: verifica o tomador e busca o cod da filial usando o CNPJ,
							// comparando com a filial do documento de carga, já que pode haver mais de uma filial com mesmo CNPJ.
							If XmlValid(oCTe,{"_INFCTE","_IDE","_TOMA3"},"",.T.) == 'toma3'
								cToma := oCTe:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
							EndIf
							If !Empty(cToma)
								If cToma == '0'              // Remetente
									cCliDes := 'Remetente'

									If XmlValid(oCTe,{"_INFCTE","_REM","_CNPJ"},"TEXT",.T.) == 'CNPJ'
										cCliIdFed := oCTe:_INFCTE:_REM:_CNPJ:TEXT
										cCliDesFed := 'CNPJ'
									Else
										cCliIdFed := oCTe:_INFCTE:_REM:_CPF:TEXT
										cCliDesFed := 'CPF'
									EndIf
								ElseIf cToma == '1'          // Expedidor
									cCliDes := 'Expedidor'

									If XmlValid(oCTe,{"_INFCTE","_EXPED","_CNPJ"},"TEXT",.T.) == 'CNPJ'
										cCliIdFed := oCTe:_INFCTE:_EXPED:_CNPJ:TEXT
										cCliDesFed := 'CNPJ'
									Else
										cCliIdFed := oCTe:_INFCTE:_EXPED:_CPF:TEXT
										cCliDesFed := 'CPF'
									EndIf
								ElseIf cToma == '2'          // Recebedor
									cCliDes := 'Recebedor'

									If XmlValid(oCTe,{"_INFCTE","_RECEB","_CNPJ"},"TEXT",.T.) == 'CNPJ'
										cCliIdFed := oCTe:_INFCTE:_RECEB:_CNPJ:TEXT
										cCliDesFed := 'CNPJ'
									Else
										cCliIdFed := oCTe:_INFCTE:_RECEB:_CPF:TEXT
										cCliDesFed := 'CPF'
									EndIf
								ElseIf cToma == '3'          // Destinatario
									cCliDes := 'Destinatário'

									If XmlValid(oCTe,{"_INFCTE","_DEST","_CNPJ"},"TEXT",.T.) == 'CNPJ'
										cCliIdFed := oCTe:_INFCTE:_DEST:_CNPJ:TEXT
										cCliDesFed := 'CNPJ'
									Else
										cCliIdFed := oCTe:_INFCTE:_DEST:_CPF:TEXT
										cCliDesFed := 'CPF'
									EndIf
								EndIf
							Else  //Outros

								cCliDes := 'Emitente outros'
								
								For nCont := 1 to Len(aAllFil)
									If XmlValid(oCTe,{"_INFCTE","_IDE","_TOMA4","_CNPJ"},"TEXT",.T.) == 'CNPJ'
										If AllTrim(aAllFil[nCont][18]) == oCTe:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT
											aGXG[38] := aAllFil[nCont][2]
										EndIf
									Else 
										If AllTrim(aAllFil[nCont][18]) == oCTe:_INFCTE:_IDE:_TOMA4:_CPF:TEXT
											aGXG[38] := aAllFil[nCont][2]
										EndIf
									EndIf
								Next nCont

								If XmlValid(oCTe,{"_INFCTE","_IDE","_TOMA4","_CNPJ"},"TEXT",.T.) == 'CNPJ'
									cCliIdFed := oCTe:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT
									cCliDesFed := 'CNPJ'
								Else
									cCliIdFed := oCTe:_INFCTE:_IDE:_TOMA4:_CPF:TEXT
									cCliDesFed := 'CPF'
								EndIf
							EndIf

							//Validação da filial do DF contra filial do DC.
							//Se for Exclusivo, será verificado se a filial selecionada em tela possui CNPJ do tomador do DF.
							//Se for Compartilhado, não há seleção de filial em tela e todos os XML serão importados.
							//Assim, será verificado se a filial do DC possui CNPJ do tomador do DF.
							//Caso não seja encontrado no sistema nenhum dos DC existentes no XML, não será possível validar filiais. A importação será feita, mas com erro.
							If FWModeAccess("GXG",1) == "E"
								If lFindGW1
									cFilVal := cFilGW1
								Else
									cFilVal := cFilAnt
								EndIf
							Else
								If lFindGW1
									cFilVal := cFilGW1
								Else
									cFilVal := ''
								EndIf
							EndIf

							cFilEmit := GFEA115BF(cCliIdFed,.F.,cFilVal)

							If s_INTTMS == .T. .And. s_TMSGFE == .T.
								If Empty(cFilEmit)
									cFilEmit := cFilAnt
								EndIf
								cMsgAux := "- Parâmetro (MV_INTTMS) habilitado, o arquivo será importado com os dados da filial corrente: " + cFilEmit
							Endif

							If Empty(cFilEmit)
								If cFilVal == ''
									cMsgPreVal += "- Tomador do Frete (" + cCliDes + ") com " + cCliDesFed + " " + cCliIdFed + " não cadastrado como filial no cadastro de emitentes." + CRLF
								Else
									cMsgPreVal += "- Tomador do Frete (" + cCliDes + ") com " + cCliDesFed + " " + cCliIdFed + " não possui o mesmo " + cCliDesFed + " da filial '" + cFilVal + "'." + CRLF
									cMsgPreVal += "- Este CNPJ deve estar configurado para a filial no cadastro de filiais do módulo configurador (SIGACFG)." + CRLF
								EndIf

								If FWModeAccess("GXG",1) == "E"
									//Verificar se o arquivo pertence a outra filial e não excluir da pasta. Assim:
									//1-Quando for schedule e a thread da filial do arquivo for executada, o arquivo será importado.
									//2-Quando for via ERP, será importado quando for selecionada a filial correta.

									If AllTrim(GFEA115BF(cCliIdFed, .F.)) == AllTrim('')
										cMsgAux := "Tomador do Frete (" + cCliDes + ") com " + cCliDesFed + " " + cCliIdFed + " não cadastrado como filial."
										cMsgAux += CRLF + SB15 + SB6 + "Arquivo não será importado."
									Else
										cMsgAux := "Tomador do Frete (" + cCliDes + ") com " + cCliDesFed + " " + cCliIdFed + " pertence a outra empresa/filial."
										If lTotvsColab
											cMsgAux += CRLF + SB15 + SB6 + "Aguarde o processamento da empresa/filial do documento para que a importação seja efetuada."
										EndIf
										lMoveArq   := .F.
										lCteOutFil := .T.
									EndIf
									cMsgPreVal += "- " + cMsgAux
									GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - ' + cMsgAux)

									lGravaGXG := .F. //erro que impede a importação
								EndIf
							Else
								aGXG[1] := If(FWModeAccess("GW3",1) == "E", cFilEmit, "") 
							EndIf

							//Revalidação de Emissor
							If !Empty(aGXG[1])
								nPosAux := AScan(aAllFil, {|x| Alltrim(x[2]) == Alltrim(aGXG[1])})

								If FWModeAccess("GU3",1) == "E" .And. FWModeAccess("GU3",2) == "E" .And. FWModeAccess("GU3",3) == "C"
									cAuxCodFil := xFilial("GU3")
								Else
									cAuxCodFil := If(FWModeAccess("GU3",1) == "E", Substr(aGXG[1],1,Len(aAllFil[nPos][2])), xFilial("GU3"))
								EndIf

								If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
									cEmi := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"),@cMsgPreVal, cAuxCodFil)
								Else
									cEmi := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF"),@cMsgPreVal, cAuxCodFil)
								EndIf

								If Empty(cEmi)
									aGXG[3] := ""
								Else
									If Alltrim(aGXG[3]) != Alltrim(cEmi)
										aGXG[3] := cEmi  //GXG->GXG_EMISDF - (Emissor)

										// Atribui controle de emissão de CT-e, caso esteja não esteja configurado
										cAliasGU3 := GetNextAlias()
										BeginSql Alias cAliasGU3
											SELECT GU3.R_E_C_N_O_ RECNOGU3
											FROM %Table:GU3% GU3
											WHERE GU3.GU3_FILIAL = %Exp:cAuxCodFil%
											AND GU3.GU3_CDEMIT = %Exp:cEmi%
											AND GU3.GU3_TRANSP = '1'
											AND GU3.GU3_CTE = '2'
											AND GU3.%NotDel%
										EndSql 
										If (cAliasGU3)->(!Eof())
											GU3->(dbGoTo((cAliasGU3)->RECNOGU3))
											RecLock('GU3',.F.)
												GU3->GU3_CTE := '1'
											GU3->(MsUnLock())
										EndIf
										(cAliasGU3)->(dbCloseArea())
									EndIf
								EndIf
							EndIf


							If lGravaGXG
								//Se não achar nenhuma nota, indica que são notas de compras em que haverá somente o pagamento do frete.
								//Nesse caso deverá ser permitido importar com erro, para dar entrada nas notas posteriormente.
								If !lFindGW1
									cMsgPreVal += "- Nenhuma nota fiscal do CT-e encontrada como Documento de Carga. Este CT-e foi importado com erro,"
									cMsgPreVal += " caso os documento de carga sejam implantados posteriormente, basta reprocessar este registro." + CRLF
									cMsgPreVal += "- Somente para nota complementar verifique a (Tag _NDOC) no CT-e importado."
									cMsgPreVal += " Com o número do CT-e origem, verifique se os documentos de carga relacionados a este CT-e estão implantados." + CRLF
								Else
									If FWModeAccess("GW3",1) == "E" .And. cFilEmit <> cFilGW1
										cMsgPreVal += "- Filiais diferentes entre Documento de Carga: '" + cFilGW1 + "' e Documento de Frete: '" + cFilEmit + "'." + CRLF
										If FWModeAccess("GXG",1) == "E"
											cMsgAux := "Filiais diferentes entre Documento de Carga: '" + cFilGW1 + "' e Documento de Frete: '" + cFilEmit + "'."
											cMsgAux += CRLF + SB15 + SB6 + "Não será importado."
											GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - ' + cMsgAux)

											lGravaGXG := .F. //erro que impede a importação
										EndIf
									EndIf
								EndIf
							EndIf
							If lGravaGXG
								aGXG[9] := CteTPDF(oCTE, aGXG, aGXH)
								// Complemento de Valores / Imposto
								If Len(aGXH) == 0 .And. cTpCte == "1"
									cChaveRel := XmlValid(oCTe,{'_INFCTE','_INFCTECOMP'},'_CHCTE')
									nCont := 1
									If !Empty(cChaveRel)
										// Adicionar notas do CT-e relacionados
										If ValidSIX("GW3", "E")
											cAliasGW4 := GetNextAlias()
											BeginSql Alias cAliasGW4
												SELECT GW4.GW4_FILIAL,
														GW4.GW4_EMISDC,
														GW4.GW4_SERDC,
														GW4.GW4_NRDC,
														GW4.GW4_TPDC,
														GU3.GU3_IDFED
												FROM %Table:GW3% GW3
												INNER JOIN %Table:GW4% GW4
												ON GW4.GW4_FILIAL = GW3.GW3_FILIAL
												AND GW4.GW4_EMISDF = GW3.GW3_EMISDF
												AND GW4.GW4_CDESP = GW3.GW3_CDESP
												AND GW4.GW4_SERDF = GW3.GW3_SERDF
												AND GW4.GW4_NRDF = GW3.GW3_NRDF
												AND GW4.%NotDel%
												INNER JOIN  %Table:GU3% GU3
												ON GU3.GU3_FILIAL = %xFilial:GU3%
												AND GU3.GU3_CDEMIT = GW4.GW4_EMISDC
												AND GU3.GU3_SIT = '1'
												AND GU3.%NotDel%
												WHERE GW3.GW3_CTE = %Exp:cChaveRel%
												AND GW3.%NotDel%
											EndSql

											Do While (cAliasGW4)->(!Eof())
												aTemp := Array(8)
												aTemp[1] := (cAliasGW4)->GW4_FILIAL  //GXH_FILIAL
												aTemp[2] := nCont                    //GXH_SEQ
												aTemp[3] := (cAliasGW4)->GW4_EMISDC  //GXH_EMISDC
												aTemp[4] := (cAliasGW4)->GW4_SERDC   //GXH_SERDC
												aTemp[5] := (cAliasGW4)->GW4_NRDC    //GXH_NRDC
												aTemp[6] := (cAliasGW4)->GW4_TPDC    //GXH_TPDC
												aTemp[7] := ""
												aTemp[8] := (cAliasGW4)->GU3_IDFED
												
												aADD(aGXH,aTemp)

												cFilGW1 := (cAliasGW4)->GW4_FILIAL
												nCont++
												(cAliasGW4)->(dbSkip())
											EndDo
											(cAliasGW4)->(dbCloseArea())
										EndIf

										// Se não encontrar nos documentos de frete busca na GXG
										If Len(aGXH) == 0 .And. ValidSIX("GXG", "5")
											cAliasGXH := GetNextAlias()
											BeginSql Alias cAliasGXH
												SELECT GXH.GXH_FILDC,
														GXH.GXH_EMISDC,
														GXH.GXH_SERDC,
														GXH.GXH_NRDC,
														GXH.GXH_TPDC,
														GXH.GXH_DANFE,
														GU3.GU3_IDFED
												FROM %Table:GXG% GXG
												INNER JOIN %Table:GXH% GXH
												ON GXH.GXH_FILIAL = GXG.GXG_FILIAL
												AND GXH.GXH_NRIMP = GXG.GXG_NRIMP
												AND GXH.%NotDel%
												INNER JOIN  %Table:GU3% GU3
												ON GU3.GU3_FILIAL = %xFilial:GU3%
												AND GU3.GU3_CDEMIT = GXH.GXH_EMISDC
												AND GU3.GU3_SIT = '1'
												AND GU3.%NotDel%
												WHERE GXG.GXG_CTE = %Exp:cChaveRel%
												AND GXG.%NotDel%
											EndSql
											Do While (cAliasGXH)->(!Eof())
												aTemp := Array(8)
												aTemp[1] := (cAliasGXH)->GXH_FILDC  //GXH_FILDC - Deve ser do documento e não da importação
												aTemp[2] := nCont                   //GXH_SEQ
												aTemp[3] := (cAliasGXH)->GXH_EMISDC //GXH_EMISDC
												aTemp[4] := (cAliasGXH)->GXH_SERDC  //GXH_SERDC
												aTemp[5] := (cAliasGXH)->GXH_NRDC   //GXH_NRDC
												aTemp[6] := (cAliasGXH)->GXH_TPDC   //GXH_TPDC
												aTemp[7] := (cAliasGXH)->GXH_DANFE
												aTemp[8] := (cAliasGXH)->GU3_IDFED

												aADD(aGXH,aTemp)

												nCont++
												(cAliasGXH)->(dbSkip())
											EndDo
											(cAliasGXH)->(dbCloseArea())
										EndIf
									EndIf
								EndIf

								// Validação de Emissor
								If Empty(cEmi)
									If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
										cEmi := A118EMIT("1",XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"),aGXH)
									Else
										cEmi := A118EMIT("1",XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF"),aGXH)
									EndIf
								EndIf
								If Empty(cEmi)
									If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
										cMsgPreVal += "- Não foi encontrado transportador válido com o CNPJ: " + XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ") + CRLF
									Else
										cMsgPreVal += "- Não foi encontrado transportador válido com o CPF: " + XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF") + CRLF
									EndIf
									aGXG[3] := ""
								Else
									aGXG[3] := cEmi  //GXG->GXG_EMISDF - (Emissor)

									// Atribui controle de emissão de CT-e, caso esteja não esteja configurado
									cAliasGU3 := GetNextAlias()
									BeginSql Alias cAliasGU3
										SELECT GU3.R_E_C_N_O_ RECNOGU3
										FROM %Table:GU3% GU3
										WHERE GU3.GU3_FILIAL = %xFilial:GU3%
										AND GU3.GU3_CDEMIT = %Exp:cEmi%
										AND GU3.GU3_TRANSP = '1'
										AND GU3.GU3_CTE = '2'
										AND GU3.%NotDel%
									EndSql 
									If (cAliasGU3)->(!Eof())
										GU3->(dbGoTo((cAliasGU3)->RECNOGU3))
										RecLock('GU3',.F.)
											GU3->GU3_CTE := '1'
										GU3->(MsUnLock())
									EndIf
									(cAliasGU3)->(dbCloseArea())
								EndIf

								// Validação do Remetente e Destinatário
								aGXG[7] := A118EMIT("2","",aGXH) //GXG->GXG_CDREM
								aGXG[8] := A118EMIT("3","",aGXH) //GXG->GXG_CDDEST

								cComp := ""

								If XmlChildEx(oCTE:_INFCTE:_VPREST,"_COMP") != Nil
									cComp := oCTe:_INFCTE:_VPREST:_COMP
								EndIf

								aGXG[19] := '0'
								aGXG[20] := '0'
								aGXG[21] := '0'
								aGXG[22] := 0
								nVlTaxas := 0

								cNrDF  := GFE118ZRGW3(ALLTRIM(aGXG[05]),PADR(alltrim(aGXG[02]),TamSx3("GW3_CDESP")[1]))
								
								If !Empty(cComp) .And. ValType(cComp) == "O"
									If 'FRETE PESO' == UPPER(cComp:_XNOME:TEXT)
										aGXG[19] := cComp:_VCOMP:TEXT
									ElseIf 'FRETE VALOR' ==  UPPER(cComp:_XNOME:TEXT)
										aGXG[20] := cComp:_VCOMP:TEXT
									ElseIf 'PEDAGIO' $  UPPER(cComp:_XNOME:TEXT)
										aGXG[21] := cComp:_VCOMP:TEXT
									Else
										nVlTaxas := val(cComp:_VCOMP:TEXT) + nVlTaxas

										if GFXCP12131("GZZ_NRDF")

											GFE118TAX(cNrDF, cComp:_XNOME:TEXT,cComp:_VCOMP:TEXT)
										Endif

									Endif
								ElseIf !Empty(cComp) .And. ValType(cComp) == "A"
									nFCont := Len(cComp)
									For nX := 1 To nFCont
										If 'FRETE PESO' ==  UPPER(cComp[nX]:_XNOME:TEXT)
											aGXG[19] := cComp[nX]:_VCOMP:TEXT// XmlValid(oCTe,{"_INFCTE","_VPREST","_COMP"},"_VCOMP")    GXG->GXG_FRPESO - Frete Peso
										ElseIf  'FRETE VALOR' ==  UPPER(cComp[nX]:_XNOME:TEXT)
											aGXG[20] := cComp[nX]:_VCOMP:TEXT//XmlValid(oCTe,{"_INFCTE","_INFCTECOMP","_VPRESCOMP","_COMPCOMP"},"_VCOMP")    //GXG->GXG_FRVAL - Frete Valor
										ElseIf  'PEDAGIO' $ UPPER(cComp[nX]:_XNOME:TEXT)
											aGXG[21] := cComp[nX]:_VCOMP:TEXT//XmlValid(oCTe,{"_INFCTE","_INFCTECOMP","_VPRESCOMP","_COMPCOMP"},"_VCOMP") //GXG->GXG_PEDAG - Pegadio
										Else
											nVlTaxas := val(cComp[nX]:_VCOMP:TEXT) + nVlTaxas // XmlValid(oCTe,{"_INFCTE","_INFCTECOMP","_VPRESCOMP","_COMPCOMP"},"_VCOMP")    //GXG->GXG_TAXAS - Taxas

											if GFXCP12131("GZZ_NRDF")

												GFE118TAX(cNrDf, cComp[nX]:_XNOME:TEXT,cComp[nX]:_VCOMP:TEXT)
											Endif
										
										EndIf
									Next nX
								EndIf

								cVTPrest := XmlValid(oCTe,{"_INFCTE","_VPREST"},"_VTPREST")
								cVRec    := XmlValid(oCTE,{"_INFCTE","_VPREST"},"_VREC")

								aGXG[22] := Str(nVlTaxas)
								aGXG[23] := IIf(QtdComp(Val(cVTPrest)) >= QtdComp(Val(cVRec)), cVTPrest, cVRec) //GXG->GXG_VLDF
								aGXG[24] := aOriDoc[1]      //GXG->GXG_ORISER
								aGXG[25] := aOriDoc[2]      //GXG->GXG_ORINR
								aGXG[26] :='I'              //GXG->GXG_ACAO - Inclusão
								aGXG[28] :=''               //GXG->GXG_EDIMSG
								aGXG[29] :=''               //GXG->GXG_EDINRL
								aGXG[30] :=''               //GXG->GXG_EDILIN
								aGXG[31] := cXMLFile        //GXG->GXG_EDIARQ
								aGXG[32] := DDATABASE       //GXG->GXG_DTIMP
								aGXG[34] := XmlValid(oCTe,{"_INFCTE","_IDE"},"_TPCTE")
								aGXG[35] := 0
								aGXG[36] := 0

								// Atribui as informações do município e estado origem/destino
								codCidIni   := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunIni")
								codUFIni    := XmlValid(oCTe,{"_INFCTE","_IDE"},"_UFIni")
								codCidFim   := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunFim")
								codUFFim    := XmlValid(oCTe,{"_INFCTE","_IDE"},"_UFFim")

								If (aGXG[13] == '7')
									dvlIcmsTRet := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vICMSSTRet")
									If XmlChildEx(oCTE:_INFCTE:_IMP:_ICMS:_ICMS60,"_VCRED") != Nil
										dvCred 	  := XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vCred")
									EndIf
									aGXG[35]    := VAL(dvlIcmsTRet)-VAL(dvCred)
									codCidIni   := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunIni")
									codUFIni    := XmlValid(oCTe,{"_INFCTE","_IDE"},"_UFIni")
									codCidFim   := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunFim")

									codUFTrp    := XmlValid(oCTe,{"_INFCTE","_IDE"},"_UFEnv")  //UF de onde o Cte foi emitido

									If (VAL(dvCred) == 0) .And. (codUFTrp != codUFIni) //transp prestando serviço em outra UF
										aGXG[13] := '3'
									EndIf

									If (VAL(dvlIcmsTRet) <> 0)
										nPossuiIcms := 1
									Else
										nPossuiIcms := 2
									EndIf

									aRetICMS := GFEFnIcms( aGXG[03], ;         // Código do transportador
															aGXG[07],;         // Código do remetente
															aGXG[08],;         // Código do destinatario
															codCidIni,;        // Número da cidade de origem
															codCidFim,;        // Número da cidade de destino
															'0',;              // Forma de utilização da mercadoria
															'0',;              // Tipo de item
															'0',;              // Classificação de frete
															CHR(nPossuiIcms),; // Mercadoria é tributada de ICMS?
															"0",;              //Tipo de Operação do Agrupador do Documento de Carga
															xFilial("GXG"))    // Filial do cálculo - Usado no parâmetro MV_GFECRIC para as exceções das filiais que não tem direito a crédito

									aGXG[36] := aRetICMS[4] // Retorno do valor do percentual de ICMS
								EndIf

								//-------------------------------------------------------------------------------------------------------------
								// Valida Valor do pedagio na Base de calculo de ICMS
								//-------------------------------------------------------------------------------------------------------------
								If aGXG[13] $ '2;3;4;6;7' ;
									.And. (XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},"_VBC") == "0.00" ;
									.Or. XmlValid(oCte,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},"_vBCOutraUF") == "0.00" ;
									.Or. XmlValid(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},"_vBCSTRet") == "0.00")

									// Busca o código da cidade
									codCidIni  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunIni")
									cAliasGU7 := GetNextAlias()
									BeginSql Alias cAliasGU7
										SELECT GU7.GU7_CDUF
										FROM %Table:GU7% GU7
										WHERE GU7.GU7_FILIAL = %xFilial:GU7%
										AND GU7.GU7_NRCID = %Exp:codCidIni%
										AND GU7.GU7_SIT = '1'
										AND GU7.%NotDel%
									EndSql
									cUFOrigem  := (cAliasGU7)->GU7_CDUF
									(cAliasGU7)->(dbCloseArea())

									// Busca a aliquota de icms
									cAliasGUT := GetNextAlias()
									BeginSql Alias cAliasGUT
										SELECT GUT.GUT_UF,
												GUT.GUT_ICMPDG
										FROM %Table:GUT% GUT
										WHERE GUT.GUT_FILIAL = %xFilial:GUT%
										AND GUT.GUT_UF = %Exp:cUFOrigem%
										AND GUT.%NotDel%
									EndSql
									If (cAliasGUT)->(!Eof())
										aGUT[1]	:= (cAliasGUT)->GUT_UF
										aGUT[2]	:= (cAliasGUT)->GUT_ICMPDG
									EndIf
									(cAliasGUT)->(dbCloseArea())
									
									If 	aGUT[2] == '2'
										aGXG[15] := CValToChar(VAL(aGXG[15]) - VAL(aGXG[21]))
										aGXG[14] := CValToChar(VAL(aGXG[15]) * VAL(aGXG[16]) / 100)
									Else
										aGXG[15] := aGXG[23]
									EndIf
								EndIf

								// Formatação de valores
								If !Empty(aGXG[14]) ; aGXG[14] := VAL(Transform(VAL(aGXG[14]), '@R 99999.99'))        ;EndIf
								If !Empty(aGXG[15]) ; aGXG[15] := VAL(Transform(VAL(aGXG[15]), '@R 9999999999999.99'));EndIf
								If !Empty(aGXG[16]) ; aGXG[16] := VAL(Transform(VAL(aGXG[16]), '@R 99.99'))           ;EndIf
								If !Empty(aGXG[18]) ; aGXG[18] := VAL(Transform(VAL(aGXG[18]), '@R 99999.99'))        ;EndIf
								If !Empty(aGXG[19]) ; aGXG[19] := VAL(Transform(VAL(aGXG[19]), '@R 9999999999999.99'));EndIf
								If !Empty(aGXG[20]) ; aGXG[20] := VAL(Transform(VAL(aGXG[20]), '@R 9999999999999.99'));EndIf
								If !Empty(aGXG[21]) ; aGXG[21] := VAL(Transform(VAL(aGXG[21]), '@R 9999999999999.99'));EndIf
								If !Empty(aGXG[22]) ; aGXG[22] := VAL(Transform(VAL(aGXG[22]), '@R 9999999999999.99'));EndIf
								If !Empty(aGXG[23]) ; aGXG[23] := VAL(Transform(VAL(aGXG[23]), '@R 9999999999999.99'));EndIf

								GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Início da gravação dos registros de importação.')

								lImportaCte := .T.
								//(Numero da Importação) - Busca o numero sequencial
								nNRIMP := SubStr(FWUUIDV4(),1,nGXG_NRIMP)

								//Substitui o codigo IBGE pelo codigo sequencial da cidade e Uf cadastrada na GU7
								If !Empty(nAuxCidIni) .Or. !Empty(nAuxCidFim)
									codCidIni := nAuxCidIni
									codCidFim := nAuxCidFim
									codUFIni  := cAuxUFIni 
									codUFFim  := cAuxUFFim
								EndIf
								
								RecLock("GXG",.T.)
									GXG->GXG_NRIMP  :=  nNRIMP
									If !IsBlind() .And. !lTotvsColab
										GXG->GXG_MARKBR := oBrowse115:Mark()
									EndIf
									GXG->GXG_FILIAL :=	xFilial("GXG",aGXG[01])
									GXG->GXG_FILDOC :=	aGXG[01]
									GXG->GXG_CDESP  :=	aGXG[02]
									GXG->GXG_EMISDF :=	aGXG[03]
									GXG->GXG_SERDF  :=	aGXG[04]
									GXG->GXG_NRDF   :=	aGXG[05]
									GXG->GXG_DTEMIS :=	aGXG[06]
									GXG->GXG_CDREM  :=	aGXG[07]
									GXG->GXG_CDDEST :=	aGXG[08]
									GXG->GXG_DTENT  :=	aGXG[10]
									GXG->GXG_CDCONS :=	aGXG[11]
									GXG->GXG_CFOP   :=	aGXG[12]
									GXG->GXG_TRBIMP :=	aGXG[13]
									GXG->GXG_VLIMP  :=	SetField(aGXG[14] ,"GXG_VLIMP" )
									GXG->GXG_BASIMP := 	SetField(aGXG[15] ,"GXG_BASIMP")
									GXG->GXG_PCIMP  :=	SetField(aGXG[16] ,"GXG_PCIMP" )
									GXG->GXG_PESOR  :=	SetField(aGXG[18] ,"GXG_PESOR" )
									GXG->GXG_FRPESO :=	SetField(aGXG[19] ,"GXG_FRPESO")
									GXG->GXG_FRVAL  :=	SetField(aGXG[20] ,"GXG_FRVAL" )
									GXG->GXG_PEDAG  :=	SetField(aGXG[21] ,"GXG_PEDAG" )
									GXG->GXG_TAXAS  :=	SetField(aGXG[22] ,"GXG_TAXAS" )
									GXG->GXG_ORISER :=	aGXG[24]
									GXG->GXG_ORINR  :=	aGXG[25]
									GXG->GXG_ACAO   :=	aGXG[26]
									GXG->GXG_EDIARQ :=	aGXG[31]
									GXG->GXG_DTIMP  :=	aGXG[32]
									GXG->GXG_CTE    :=	aGXG[33]
									GXG->GXG_TPCTE  :=	aGXG[34]
									If GFXCP12137('GXG_FILTOM')
										GXG->GXG_FILTOM :=	aGXG[38]
									EndIf
									If GFXCP2510('GXG_XMLTRB')
										aGXG[39] := cBufSTR
										GXG->GXG_XMLTRB :=	aGXG[39]
									EndIf
									GXG->GXG_IMPRET :=	SetField(aGXG[35] ,"GXG_IMPRET")
									GXG->GXG_PCRET  :=	SetField(aGXG[36] ,"GXG_PCRET" )
									GXG->GXG_ORIGEM :=	'2' //CT-e
									GXG->GXG_ALTER  :=	'2'
									GXG->GXG_OBS    :=	cObs

									If aGXG[09] == '2' .and. SetField(aGXG[23] ,"GXG_VLDF"  ) == 0
										GXG->GXG_TPDF := '3'
										GXG->GXG_VLDF := 0  // GXG->GXG_BASIMP
									Else
										GXG->GXG_TPDF  :=	aGXG[09]
										GXG->GXG_VLDF   :=	SetField(aGXG[23] ,"GXG_VLDF"  )
									EndIf

									GXG->GXG_QTDCS  := nNF
									GXG->GXG_VLCARG := SetField(CalcVlCar(), "GXG_VLCARG")
									CalcVolum()

									If (aGXG[13] == '6')	.and. empty(GXG->GXG_BASIMP)
										GXG->GXG_BASIMP := GXG->GXG_VLDF
									EndIf

									If (aGXG[13] == "3")
										GXG->GXG_IMPRET := GXG->GXG_VLIMP
									ElseIf (aGXG[13] == "7")
										GXG->GXG_IMPRET := GXG->GXG_VLIMP * (1 - (aGXG[36] / 100))
									EndIf

									If !Empty(cMsgPreVal)
										GXG->GXG_EDISIT := '2'
									Else
										GXG->GXG_EDISIT := '1'
									EndIf

									If aGXG[37] == '5'
										GXG->GXG_EDISIT := '5'
									EndIf
									// Atribui os códigos de cidade/UF de origem e destino
									If !Empty(codCidIni) .And. GFXCP12131("GXG_MUNINI")
										GXG->GXG_MUNINI := codCidIni
									EndIf
									If !Empty(codUFIni) .And. GFXCP12131("GXG_UFINI")
										GXG->GXG_UFINI := codUFIni
									EndIf
									If !Empty(codCidFim) .And. GFXCP12131("GXG_MUNFIM")
										GXG->GXG_MUNFIM := codCidFim
									EndIf
									If !Empty(codCidIni) .And. GFXCP12131("GXG_UFFIM")
										GXG->GXG_UFFIM := codUFFim
									EndIf
									If GFXCP2510('GXG_CTESUB')
										GXG->GXG_CTESUB := cChaveCteSub
									EndIf
									GXG->GXG_EDIMSG := cMsgPreVal
									GXG->GXG_USUIMP := cUserName
								GXG->(MsUnlock())

								nFCont :=  Len(aGXH)
								For nCont := 1 To nFCont
									nSeq := PadL(Alltrim(Transform(nCont, '@R 99999')),5,"0")
									RecLock("GXH",.T.)
										GXH->GXH_FILIAL := xFilial("GXH",aGXH[nCont][1])
										GXH->GXH_FILDC  := aGXH[nCont][1]
										GXH->GXH_NRIMP  := nNRIMP
										GXH->GXH_SEQ    := nSeq
										GXH->GXH_EMISDC := aGXH[nCont][3]
										GXH->GXH_SERDC  := aGXH[nCont][4]
										GXH->GXH_NRDC   := aGXH[nCont][5]
										GXH->GXH_TPDC   := aGXH[nCont][6]
										GXH->GXH_DANFE 	:= aGXH[nCont][7]
										GXH->GXH_CNPJEM := aGXH[nCont][8]
									GXH->(MsUnlock())
								Next

								If ExistBlock("GFEA1181")
									ExecBlock("GFEA1181",.F.,.F.,{oCTE})
								EndIf

								GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Fim da gravação dos registros de importação.')
							EndIf
						EndIf
					EndIf
					(cAliasGXG)->(dbCloseArea())
				EndIf
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Fim da validação do conteúdo do arquivo.')
			EndIf
		EndIf
	EndIf
	If lContinua
		//Não deve mover o arquivo quando for CTe de outra filial ou houver problemas de falta de patch etc.
		If lMoveArq
			If lTotvsColab
				// Verificar inicio de Totvscolaboração - MOBI
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Início da movimentação do arquivo por COMXCOL.')

				If lTC20
					//Para TC 2.0:
					//Quando executado via GFEA118, o arquivo deverá existir. Assim, o GFEA118 moverá o arquivo para pasta lidos.
					//Quando executado via ComXCol, o Job ColAutoRead "consome" o arquivo, criando um registro na
					//tabela CKO, e move o arquivo para pasta lidos. O Job SchdComCol fará a leitura dos registros dessa tabela,
					//para então chamar o GFEA118, que não irá mover o arquivo, apenas criar os registros GXG e GXH.
					//No TC 2.0, sempre move para pasta de lidos, independente de haver erro ou não.
					//Neste ponto não há necessidade de manipulação de arquivo físico.

					GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Utilizando configuração do TOTVS COLABORACAO 2.0.')
					GFELog118:Add(SB15 + SB6 + 'Não há movimentação de arquivo.')
				Else
					If ExistBlock("GFEA1182")
						cDIROK := ExecBlock("GFEA1182",.F.,.F.)
					EndIf

					GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Utilizando configuração do TOTVS COLABORACAO 1.0.')

					If !Empty(cDIROK)
						GA118MoveFile(If(lIsLinux, DIRXMLLNX+DIRALERLNX+AllTrim(cXMLFile), DIRXML+DIRALER+AllTrim(cXMLFile)), cDIROK+AllTrim(cXMLFile), @GFELog118)
					Else
						GA118MoveFile(If(lIsLinux, DIRXMLLNX+DIRALERLNX+AllTrim(cXMLFile), DIRXML+DIRALER+AllTrim(cXMLFile)), If(lIsLinux, DIRXMLLNX+DIRLIDOLNX+AllTrim(cXMLFile), DIRXML+DIRLIDO+AllTrim(cXMLFile) ), @GFELog118)
					EndIf
				EndIf

				//O programa sempre vai adicionar o XML mesmo se houver erros (cMsgPreVal)
				Do Case
					Case nTipoXML = 1
					aAdd(aProc,{aGXG[05],aGXG[04],aGXG[03]})
					Case nTipoXML = 2
					If XmlValid(oCTe,{"_INFCTE","_IDE","_NCT"},'TEXT',.T.) == 'NCT'

						If XmlValid(oCTe,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.)== 'CNPJ'
							cEmi := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"))
						Else
							cEmi := ValidEmis(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CPF"))
						EndIf
						aGXG[3] := ""
						aAdd(aProc,{ XmlValid(oCTe,{"_INFCTE","_IDE"},"_NCT"),XmlValid(oCTe,{"_INFCTE","_IDE"},"_SERIE"),cEmi})
					EndIf
					Case nTipoXML = 3
					If XmlValid(oCTE,{"_INFEVENTO","_CHCTE"},'TEXT',.T.) == 'CHCTE'
						If XmlValid(oCTe,{"_INFEVENTO","_CNPJ"},"TEXT",.T.)== 'CNPJ'
							cEmi := ValidEmis(XmlValid(oCTe,{"_INFEVENTO"},"_CNPJ"))
						Else
							cEmi := ValidEmis(XmlValid(oCTe,{"_INFEVENTO"},"_CPF"))
						EndIf
						// Não existem informações de número e série no xml do evento de cancelamento 2.00
						// Então são usadas do documento de frete localizado ou em branco caso não encontre o DF pela chave
						If lRetFuncao
							aAdd(aProc,{GXG->GXG_NRDF,GXG->GXG_SERDF,cEmi})
						Else
							aAdd(aProc,{" "," ",cEmi})
						EndIf
					EndIf
				EndCase

				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Fim da movimentação do arquivo.')
			Else
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Início da movimentação do arquivo pelo GFEA118.')

				//No TC 2.0, move para pasta de lidos se for erro ou for importado.
				If lTC20 .And. IsBlind()
					cDirDest := GFEA118Bar(AllTrim(GetNewPar("MV_NGLIDOS","\NeoGrid\LIDOS\")))
					GA118MoveFile(cXMLFile, cDirDest+GA118ExtDirOrFileName(cXMLFile,2), @GFELog118)
				Else

					If IsBlind()
						cDirDest := GFEA118Bar(AllTrim(SuperGetMv("MV_XMLDIR", .F., "")))

						If Empty(cMsgPreVal)
							GA118MoveFile(cXMLFile, cDirDest + If(lIsLinux, DIRLIDOLNX, DIRLIDO) + GA118ExtDirOrFileName(cXMLFile,2), @GFELog118)
						Else
							GA118MoveFile(cXMLFile, cDirDest + If(lIsLinux, DIRERROLNX, DIRERRO) + GA118ExtDirOrFileName(cXMLFile,2), @GFELog118)
						EndIf
					Else
						If Empty(cMsgPreVal)
							GA118MoveFile(cXMLFile, cDirLido + GA118ExtDirOrFileName(cXMLFile,2), @GFELog118)
						Else
							GA118MoveFile(cXMLFile, cDirErro + GA118ExtDirOrFileName(cXMLFile,2), @GFELog118)
						EndIf
					EndIF
				EndIf

				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Fim da movimentação do arquivo.')
			EndIf
		EndIf
	EndIf
	If lContinua
		GFELog118:Add(GFENOW(.F.,,,':','.') + SB2 + ' - Fim da importação do arquivo.')

		//Elimina o registro de controle de concorrência de importação
		UnLockByName(cLock, .F., .F.)
		GFELog118:Add(GFENOW(.F.,,,':','.') + ' - Exclusão de semáforo para o arquivo.')
		//Redefine a variável de forma a atualizar a hora em que ela teve o valor atribuído.
		PutGlbValue(cLock, GFENow(.T.,,'','',''))

		If !lTotvsColab
			// Parâmetros são passados pelo programa COMXCOL, não podem ser "limpos" aqui.
			FreeObj(oCte)

			aSize( aProc, 0 )
			aProc := Nil

			aSize( aTemp, 0 )
			aTemp := Nil
		EndIf

		aSize( aGXH, 0 )
		aGXH := Nil

		aSize( aGXG, 0 )
		aGXG := Nil

		If !Empty(cMsgPreVal)
			//Quando for CTe de outra filial, deve setar variável para vazio de forma que o ComXCol entenda que
			//esse arquivo deverá ser reprocessado.
			If lCteOutFil .And. lTotvsColab
				aErros := {}
			Else
				AAdd(aErros, {cXMLFile, cMsgPreVal, ""})
			EndIf

			lRetFuncao := .F.

			If !lCteOutFil .And. lTotvsColab // Se colaboração e existe mensagens de inconsistencia, envia status para monitor colab verificar no SIGAGFE
				aAdd(aErros, {cXMLFile,"COM048 - Inconsistência na importação do CT-e. Verifique no SIGAGFE (GFEA118)",""})
				aAdd(aErroErp,{cXMLFile,"COM048"})
			EndIf
		EndIf

		GFELog118:EndLog()
	EndIf
Return lRetFuncao
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118ANU

Validações do arquivo Cte ou evento de cancelamento
Cria registro de exclusão

@param cXMLFile caminho do arquivo que esta sendo importado
@param aErros  armazena o caminho dos aquivos com erro
@param aProc   array para guardar os arquivos processados (M-Mess)
@param oCTE: Objeto XML do CTE
@param lTotvsColb: se a chamada da função vem do COMXCOL (importação via TSS/Totvs Colaboração)
@param cTpCte: Indicando se é cTE de anulação,substituição ou evento de cancelamento
@author Siegklenes.Beulke
@since 25/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEA118ANU(cXMLFile,aProc,cMsgPreVal, oCTE, lTotvsColab,cTpCte, cStat)
	Local lTemReg    := .F.
	Local lExcIncl   := .F.
	Local aAreaGW3   := GW3->(GetArea())
	Local aOriDoc    := {'','',.T.} //Possui a refêrencia do documento anulado/subtituido
	Local aAreaGXG   := GXG->(GetArea())
	Local cAliasGW4  := Nil
	Local cAliasGW3  := Nil
	Local cAliasGXG  := Nil
	Local cChaveCte  := ''
	Local cStatCanc  := ''
	Local cMsg       := ''
	Local cRetEvento := ''
	Local xMotivo    := Nil
	Local nNRIMP     := 0
	Local nCont      := 1
	Local cChaveCteSub  := ''

	If cTpCte == '2' .Or. cTpCte =='3' .Or. cTpCte == "110111" .Or. (cTpCte == '0' .And. cStat == '101') // Cte de Anulação/Substituição de Valores/Cancelamento
		If cTpCte == '2' // Anulação de valores
			cChaveCte := XmlValid(oCTE,{"_INFCTE","_INFCTEANU"},"_CHCTE")
		EndIf

		If cTpCte == '3' // Substituição de valores
			cChaveCte := XmlValid(oCTE,{"_INFCTE","_INFCTENORM","_INFCTESUB"},"_CHCTE") //SubStr(oCTe:_INFCTE:_ID:TEXT,4,44) 
			cChaveCteSub := XmlValid(oCTE,{"_INFCTE","_INFCTENORM","_INFCTESUB"},"_CHCTE")
		EndIf

		If cTpCte == "110111" // Evento de Cancelamento
			cRetEvento := '_RETEVENTOCTE'
			cStatCanc := XmlValid(oCTE, {cRetEvento,"_INFEVENTO"},"_CSTAT")
			If cStatCanc == '135' //indica que o evento de cancelamento foi autorizado
				cChaveCte := XmlValid(oCTE,{"_EVENTOCTE","_INFEVENTO"},"_CHCTE")
			Else
				xMotivo := XmlValid(oCTE, {cRetEvento,"_INFEVENTO"},"_XMOTIVO")
				aOriDoc[3] := .F.
				cMsg := 'Cancelamento não autorizado. Motivo: ' + If(xMotivo == NIL, 'Arquivo de CT-e Inválido. Verifique se a versão do leiaute do CT-e corresponde as Tags utilizadas no arquivo. ', xMotivo)
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - ' + cMsg)
				cMsgPreVal += '- ' + cMsg
			EndIf
		EndIf

		If cTpCte == '0' .And. cStat == '101'
			cChaveCte := SubStr(oCTe:_INFCTE:_ID:TEXT,4,44)
		EndIf

		If aOriDoc[3] == .T.
			If !Empty(cChaveCte)//Possui uma chave Ct-e
				cAliasGW3 := GetNextAlias()
				BeginSql Alias cAliasGW3
					SELECT GW3.R_E_C_N_O_ RECNOGW3,
							GW3.GW3_FILIAL,
							GW3.GW3_CDESP,
							GW3.GW3_EMISDF,
							GW3.GW3_SERDF,
							GW3.GW3_NRDF,
							GW3.GW3_DTEMIS,
							GW3.GW3_CDREM,
							GW3.GW3_CDDEST,
							GW3.GW3_TPDF,
							GW3.GW3_DTENT,
							GW3.GW3_CFOP,
							GW3.GW3_TRBIMP,
							GW3.GW3_VLIMP,
							GW3.GW3_BASIMP,
							GW3.GW3_PCIMP,
							GW3.GW3_PESOR,
							GW3.GW3_PESOC,
							GW3.GW3_FRPESO,
							GW3.GW3_FRVAL,
							GW3.GW3_PEDAG,
							GW3.GW3_TAXAS,
							GW3.GW3_VLDF,
							GW3.GW3_ORISER,
							GW3.GW3_ORINR,
							GW3.GW3_QTDCS,
							GW3.GW3_VLCARG,
							GW3.GW3_VOLUM,
							GW3.GW3_QTVOL,
							GW3.GW3_SERDF,
							GW3.GW3_NRDF
					FROM %Table:GW3% GW3
					WHERE GW3.GW3_CTE = %Exp:cChaveCte%
					AND GW3.%NotDel%
				EndSql

				//Encontra o documento baseado na chave, se encontrar, faz uma cópia
				//para tabela intermediária, permitindo futura eliminação
				If (cAliasGW3)->(!Eof())

					cAliasGXG := GetNextAlias()
					BeginSql Alias cAliasGXG
						SELECT GXG.R_E_C_N_O_ RECNOGXG,
								GXG.GXG_EDISIT,
								GXG.GXG_ACAO,
								GXG.GXG_EDISIT
						FROM %Table:GXG% GXG
						WHERE GXG.GXG_CTE = %Exp:cChaveCte%
						AND GXG.%NotDel%
					EndSql

					// Caso o CT-e Anulado,Substituído ou cancelado exista na tabela de processamento
					// e ele está pendente, excluí o regístro
					Do While (cAliasGXG)->(!Eof())
						If (cAliasGXG)->GXG_EDISIT != '4'
							GXG->(dbGoTo((cAliasGXG)->RECNOGXG))

							lImportaCTe := .T.
							GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Cancelamento ou substituição eliminou o registro pendente de processamento')
							GFELog118:Add(SB15 + SB4 + 'com a chave "' + cChaveCte + '".')
							GFEA118DEL(cChaveCte)
						EndIf

						//Se já encontrar registro de exclusão, não precisa criar outro registro.
						If (cAliasGXG)->GXG_ACAO = 'E' .And. !((cAliasGXG)->GXG_EDISIT $ '2;4')
							lTemReg := .T.
						EndIf

						(cAliasGXG)->(dbSkip())
					EndDo
					(cAliasGXG)->(dbCloseArea())

					If !lTemReg
						lImportaCte := .T.
						//Faz um cópia do documento de frete para GXG
						nNRIMP := SubStr(FWUUIDV4(),1,TamSx3("GXG_NRIMP")[1])
						RecLock("GXG",.T.)
							GXG->GXG_NRIMP  :=  nNRIMP
							If !IsBlind() .And. !lTotvsColab
								GXG->GXG_MARKBR := oBrowse115:Mark()
							EndIf
							GXG->GXG_FILIAL :=	xFilial("GXG")
							GXG->GXG_FILDOC :=	(cAliasGW3)->GW3_FILIAL
							GXG->GXG_CDESP  :=	(cAliasGW3)->GW3_CDESP
							GXG->GXG_EMISDF :=	(cAliasGW3)->GW3_EMISDF
							GXG->GXG_SERDF  :=	(cAliasGW3)->GW3_SERDF
							GXG->GXG_NRDF   :=	(cAliasGW3)->GW3_NRDF
							GXG->GXG_DTEMIS :=	StoD((cAliasGW3)->GW3_DTEMIS)
							GXG->GXG_CDREM  :=	(cAliasGW3)->GW3_CDREM
							GXG->GXG_CDDEST :=	(cAliasGW3)->GW3_CDDEST
							GXG->GXG_TPDF   :=	(cAliasGW3)->GW3_TPDF
							GXG->GXG_DTENT  :=	StoD((cAliasGW3)->GW3_DTENT)
							GXG->GXG_CDCONS :=	''
							GXG->GXG_CFOP   :=	(cAliasGW3)->GW3_CFOP
							GXG->GXG_TRBIMP :=	(cAliasGW3)->GW3_TRBIMP
							GXG->GXG_VLIMP  :=	(cAliasGW3)->GW3_VLIMP
							GXG->GXG_BASIMP :=	(cAliasGW3)->GW3_BASIMP
							GXG->GXG_PCIMP  :=	(cAliasGW3)->GW3_PCIMP
							GXG->GXG_PESOR  :=	(cAliasGW3)->GW3_PESOR
							GXG->GXG_PESOC  :=	(cAliasGW3)->GW3_PESOC
							GXG->GXG_FRPESO :=	(cAliasGW3)->GW3_FRPESO
							GXG->GXG_FRVAL  :=	(cAliasGW3)->GW3_FRVAL
							GXG->GXG_PEDAG  :=	(cAliasGW3)->GW3_PEDAG
							GXG->GXG_TAXAS  :=	(cAliasGW3)->GW3_TAXAS
							GXG->GXG_VLDF   :=	(cAliasGW3)->GW3_VLDF
							GXG->GXG_ORISER :=	(cAliasGW3)->GW3_ORISER
							GXG->GXG_ORINR  :=	(cAliasGW3)->GW3_ORINR
							GXG->GXG_ACAO   :=	'E' //Exclusão
							GXG->GXG_EDISIT :=	'1' //1=Importado com sucesso,2=Importado com erros
							GXG->GXG_EDIMSG :=	"" //Mensagem informativa
							GXG->GXG_EDIARQ :=	cXMLFile
							GXG->GXG_DTIMP  :=	dDatabase
							GXG->GXG_CTE    :=	cChaveCte

							GXG->GXG_ORIGEM :=	'2' //CT-e
							GXG->GXG_ALTER  :=	'2'

							If Len(cTpCte) == 1
								GXG->GXG_TPCTE	:= cTpCte
							ElseIf cTpCte == "110111"
								GXG->GXG_TPCTE	:= "2"
							EndIf

							GXG->GXG_QTDCS  := (cAliasGW3)->GW3_QTDCS
							GXG->GXG_VLCARG := (cAliasGW3)->GW3_VLCARG
							GXG->GXG_VOLUM	:= (cAliasGW3)->GW3_VOLUM
							GXG->GXG_QTVOL	:= (cAliasGW3)->GW3_QTVOL
							GXG->GXG_USUIMP := cUserName
						GXG->(MsUnlock())

						If GXG->GXG_TPCTE == '3'

							GW3->(dbGoTo((cAliasGW3)->RECNOGW3))
							RecLock("GW3",.F.)
								GW3->GW3_OBS += " #infctesub# Ct-e substituído conforme arquivo " + GXG->GXG_EDIARQ + "."
							GW3->(MsUnlock())
						EndIf

						aOriDoc[1] := (cAliasGW3)->GW3_SERDF
						aOriDoc[2] := (cAliasGW3)->GW3_NRDF

						cAliasGW4 := GetNextAlias()
						BeginSql Alias cAliasGW4
							SELECT GW4.GW4_EMISDC,
									GW4.GW4_SERDC,
									GW4.GW4_NRDC,
									GW4.GW4_TPDC,
									GW4.GW4_FILIAL
							FROM %Table:GW4% GW4
							WHERE GW4.GW4_FILIAL = %Exp:(cAliasGW3)->GW3_FILIAL%
							AND GW4.GW4_EMISDF = %Exp:(cAliasGW3)->GW3_EMISDF%
							AND GW4.GW4_CDESP = %Exp:(cAliasGW3)->GW3_CDESP%
							AND GW4.GW4_SERDF = %Exp:(cAliasGW3)->GW3_SERDF%
							AND GW4.GW4_NRDF = %Exp:(cAliasGW3)->GW3_NRDF%
							AND GW4.%NotDel%
						EndSql

						Do While (cAliasGW4)->(!Eof())
							RecLock("GXH",.T.)
								GXH->GXH_NRIMP  := nNRIMP
								GXH->GXH_FILIAL := GXG->GXG_FILIAL
								GXH->GXH_SEQ    := StrZero(nCont,5)
								GXH->GXH_EMISDC := (cAliasGW4)->GW4_EMISDC
								GXH->GXH_SERDC  := (cAliasGW4)->GW4_SERDC
								GXH->GXH_NRDC   := (cAliasGW4)->GW4_NRDC
								GXH->GXH_TPDC   := (cAliasGW4)->GW4_TPDC
								GXH->GXH_FILDC  := (cAliasGW4)->GW4_FILIAL
								GXH->(MsUnLock())
							nCont++
							(cAliasGW4)->(dbSkip())
						EndDo
						(cAliasGW4)->(dbCloseArea())
					EndIf
				Else // Não encontrou documento de frete para anular/substituir ou cancelar
					cAliasGXG := GetNextAlias()
					BeginSql Alias cAliasGXG
						SELECT GXG.R_E_C_N_O_ RECNOGXG,
								GXG.GXG_EDISIT,
								GXG.GXG_ACAO,
								GXG.GXG_EDISIT
						FROM %Table:GXG% GXG
						WHERE GXG.GXG_CTE = %Exp:cChaveCte%
						AND GXG.%NotDel%
					EndSql
					Do While (cAliasGXG)->(!Eof())
						If (cAliasGXG)->GXG_EDISIT != '4' .And. (cAliasGXG)->GXG_ACAO == 'I'
							GXG->(dbGoTo((cAliasGXG)->RECNOGXG))
							//Elimina registro não processado de inclusão
							lExcIncl := .T.
							GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Cancelamento ou substituição eliminou o registro de inclusão pendente de processamento')
							GFELog118:Add(SB15 + SB4 + 'com a chave "' + cChaveCte + '".')
							GFEA118DEL(cChaveCte)
						ElseIf (cAliasGXG)->GXG_EDISIT != '4' .And. (cAliasGXG)->GXG_ACAO == 'E'
							If (cAliasGXG)->GXG_EDISIT != '2'
								lTemReg := .T.
							Else
								GXG->(dbGoTo((cAliasGXG)->RECNOGXG))
								//Elimina registro importado com erro de exclusão
								GFELog118:Add(GFENOW(.F.,,,':','.') + SB4 + ' - Cancelamento ou substituição eliminou o registro de exclusão pendente de processamento')
								GFELog118:Add(SB15 + SB4 + 'com a chave "' + cChaveCte + '".')
								GFEA118DEL(cChaveCte)
							EndIf
						EndIf
						(cAliasGXG)->(dbSkip())
					EndDo
					(cAliasGXG)->(dbCloseArea())
					If !lTemReg
						//Caso não exista será criado um regristro de exclusão com a chave do Conhecimento
						//para processamento futuro
						nNRIMP := SubStr(FWUUIDV4(),1,TamSx3("GXG_NRIMP")[1])
						RecLock("GXG",.T.)
							GXG->GXG_NRIMP  :=  nNRIMP

							If !IsBlind() .And. !lTotvsColab
								GXG->GXG_MARKBR := oBrowse115:Mark()
							EndIf
							GXG->GXG_FILIAL :=	xFilial("GXG")
							GXG->GXG_ACAO   :=	'E' //Exclusão
							GXG->GXG_EDISIT :=	If(lExcIncl,'4','2') //1=Importado com sucesso,2=Importado com erros,4=Processado com sucesso
							GXG->GXG_CTE    :=	cChaveCte
							If lExcIncl
								GXG->GXG_EDIMSG :=	"Não existe o documento de frete com a Chave CT-e " + cChaveCte  + "." + CRLF + "Os conhecimentos relacionados, pendentes de processamento, foram eliminados." //Mensagem informativa
							Else
								GXG->GXG_EDIMSG :=	"Não existe o documento de frete com a Chave CT-e " + cChaveCte //Mensagem informativa
								cMsgPreVal := GXG->GXG_EDIMSG
							EndIf
							GXG->GXG_EDIARQ :=	cXMLFile
							GXG->GXG_DTIMP  :=	dDatabase
							GXG->GXG_ORIGEM :=	'2' //CT-e
							GXG->GXG_ALTER  :=	'2'
							GXG->GXG_USUIMP := cUserName
						GXG->(MsUnlock())
					EndIf

					lImportaCte := .T.

				EndIf
				(cAliasGW3)->(dbCloseArea())
			Else //Deveria possuir a chave ct-e anulada
				aOriDoc[3] := .F.
				cMsgPreVal += "- Chave do CTe não encontrada no arquivo."
			EndIf
		EndIf
	EndIf
	RestArea(aAreaGXG)
	RestArea(aAreaGW3)
Return aOriDoc
//-------------------------------------------------------------------
/*/{Protheus.doc} CteTPDF
Retorna qual o tipo de documento de frete a ser atribuído ao CT-e sendo importado.

O tipo é definido utilizando uma combinação das seguintes tags do arquivo Ct-e:
- tpCte
- tpServ
- xCaracAd
- vRec

@param oCte Arquivo Ct-e

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CteTPDF(oCTE, aGXG, aGXH)
	Local aRet       	:= {.F., ''}
	Local cAliasGWU  	:= Nil
	Local cTPDF      	:= '1'
	Local cTpCte     	:= ''
	Local cTpServ    	:= ''
	Local cXCaracAd  	:= ''
	Local cVRec      	:= ''
	Local codCidIni  	:= ''
	Local codCidFim  	:= ''
	Local nomCidIni  	:= ''
	Local nomCidFim  	:= ''
	Local cNmCidIni  	:= ''
	Local cNmCidFim  	:= ''
	Local nomUFIni   	:= ''
	Local nomUFFim   	:= ''
	Local cAliasGU7  	:= Nil
	Local cAliasGU7Ini  := Nil
	Local cAliasGU7Fim	:= Nil

	cTpCte    := XmlValid(oCTE,{"_INFCTE","_IDE"},"_TPCTE")
	cTpServ   := XmlValid(oCTE,{"_INFCTE","_IDE"},"_TPSERV")
	cVRec     := XmlValid(oCTE,{"_INFCTE","_VPREST"},"_VREC")
	codCidIni := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunIni")
	codCidFim := XmlValid(oCTe,{"_INFCTE","_IDE"},"_cMunFim")
	nomCidIni := FWNoAccent(FwQtToChr(XmlValid(oCTe,{"_INFCTE","_IDE"},"_xMunIni")))
	nomCidFim := FWNoAccent(FwQtToChr(XmlValid(oCTe,{"_INFCTE","_IDE"},"_xMunFim")))
	nomUFIni  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_UFIni")
	nomUFFim  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_UFFim")

	If XmlChildEx(oCTE:_INFCTE,"_COMPL") != Nil .And. XmlChildEx(oCTE:_INFCTE:_COMPL,"_XCARACAD") != Nil
		cXCaracAd := XmlValid(oCTE,{"_INFCTE","_COMPL"},"_XCARACAD")
	EndIf

	//Ponto de entrada
	//GFEA1184 - envia objeto CTE. Recebe array[2]
	If ExistBlock("GFEA1184")
		aRet := ExecBlock("GFEA1184",.F.,.F.,{oCTE})
	EndIf

	If aRet[1] == .T.
		cTPDF := aRet[2]
	Else
		Do Case
			// TPDF = Devolução
			Case cTpCte == '0' .And. AT('DEVOLUCAO', Upper(cXCaracAd)) <> 0  
				cTPDF := '5'

			// TPDF = Reentrega
			Case cTpCte == '0' .And. AT('REENTREGA', Upper(cXCaracAd)) <> 0
				cTPDF := '4'

			//TPDF Serviço
			Case cTpCte $ '0;1' .And. AT('SERVICO', Upper(cXCaracAd)) <> 0
				cTPDF := '7'

			// CTE COMPLEMENTAR
			Case cTpCte == '1'
				If !Empty(cVRec) .And. !Empty(aGXG[14]) .And. Val(aGXG[14]) == Val(cVRec)
					// TPDF = Complementar Imposto
					cTPDF := '3'
				Else
					// TPDF = Complementar Valor
					cTPDF := '2'
				EndIf

			// TPDF = Redespacho
			Case cTpCte == '0' .And. cTpServ $ '1;2;3;4'
				cTPDF := '6' // Redespacho

			// TPDF Padrão = Normal
			OtherWise
				cTPDF := '1'
		EndCase
		If cTPDF $ '1;6'
			// Valida se exite o trecho para o transportador na cidade origem e destino e quando for
			// o primeiro trecho o tipo de documento de frete será 1-Normal, caso contrário será 6-Redespacho
			If !Empty(aGXH) .And. !Empty(aGXH[1][1])
				cAliasGWU := GetNextAlias()
				BeginSql Alias cAliasGWU
					SELECT GWU.GWU_SEQ
					FROM %Table:GWU% GWU
					WHERE GWU.GWU_FILIAL = %Exp:aGXH[1][1]%
					AND GWU.GWU_CDTPDC = %Exp:aGXH[1][6]%
					AND GWU.GWU_EMISDC = %Exp:aGXH[1][3]%
					AND GWU.GWU_SERDC = %Exp:aGXH[1][4]%
					AND GWU.GWU_NRDC = %Exp:aGXH[1][5]%
					AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(aGXG[03])%)
					AND GWU.GWU_NRCIDO = %Exp:codCidIni%
					AND GWU.GWU_NRCIDD = %Exp:codCidFim%
					AND GWU.%NotDel%
				EndSql
				If (cAliasGWU)->(!Eof())
					cTPDF := IIf((cAliasGWU)->GWU_SEQ == '01','1','6')
				Else
					//Busca o Codigo e Nome da Cidade no Cadastro de Cidades (GU7) de acordo com o código da cidade do Documento EDI
					cAliasGU7 := GetNextAlias()
					BeginSql Alias cAliasGU7
						SELECT GU7_NRCID , GU7_NMCID
						FROM %Table:GU7% GU7 
						WHERE GU7.GU7_NRCID = %Exp:codCidIni% 
						AND GU7.%NotDel%
					EndSql

					//Verifica se a Cidade Inicial (cMunIni) do Documento EDI já está cadastrada na Tabela de Cadastro de Cidades
					If codCidIni == (cAliasGU7)->GU7_NRCID
						If "'" $ AllTrim((cAliasGU7)->GU7_NMCID)
							cMsgPreVal := "A cidade inicial " + AllTrim((cAliasGU7)->GU7_NMCID) + " contém apóstrofo no nome, por favor remova o apóstrofo no cadastro da Cidade antes da Importação"
							Return Nil
						EndIf 
						nomCidIni :=  "'"+AllTrim((cAliasGU7)->GU7_NMCID)+"'"
					Else
						// Busca pelo nome da cidade caso não encontre pelo codigo.
						nomCidIni := StrTran(nomCidIni,"'")
						cAliasGU7Ini := GetNextAlias()
						BeginSql Alias cAliasGU7Ini
							SELECT GU7_NRCID , GU7_NMCID, GU7_CDUF
							FROM %Table:GU7% GU7 
							WHERE GU7.GU7_FILIAL = %xFilial:GU7%
							AND Upper(GU7.GU7_NMCID) = Upper(%Exp:nomCidIni%)
							AND Upper(GU7.GU7_CDUF) = Upper(%Exp:nomUFIni%)
							AND GU7.%NotDel%
						EndSql
						If nomCidIni == AllTrim((cAliasGU7Ini)->GU7_NMCID) .Or. Upper(nomCidIni) == AllTrim((cAliasGU7Ini)->GU7_NMCID) 
							nomCidIni  := "'"+AllTrim((cAliasGU7Ini)->GU7_NMCID)+"'"
							nAuxCidIni := (cAliasGU7Ini)->GU7_NRCID
							cAuxUFIni  := (cAliasGU7Ini)->GU7_CDUF
						Else 
							cMsgPreVal := "Cidade Inicial não cadastrada no Sistema, por favor realize o cadastro da Cidade "+ AllTrim(nomCidIni) +" antes da Importação"
							Return Nil
						EndIf
						(cAliasGU7Ini)->(dbCloseArea())
					EndIf
					(cAliasGU7)->(dbCloseArea())
					
					//Busca o Codigo e Nome da Cidade no Cadastro de Cidades (GU7) de acordo com o código da cidade Findo Documento EDI
					cAliasGU7 := GetNextAlias()
					BeginSql Alias cAliasGU7
						SELECT GU7_NRCID , GU7_NMCID
						FROM %Table:GU7% GU7
						WHERE GU7.GU7_NRCID = %Exp:codCidFim% 
						AND GU7.%NotDel%
					EndSql
					
					//Verifica se a Cidade Final (cMunFim) do Documento EDI já está cadastrada na Tabela de Cadastro de Cidades
					If codCidFim == (cAliasGU7)->GU7_NRCID
						If "'" $ AllTrim((cAliasGU7)->GU7_NMCID)
							cMsgPreVal := "A cidade final "+ AllTrim((cAliasGU7)->GU7_NMCID) +" contém apóstrofo no nome, por favor remova o apóstrofo no cadastro de Cidades antes da Importação"
							Return Nil 
						EndIf 
						nomCidFim :=  "'"+AllTrim((cAliasGU7)->GU7_NMCID)+"'"
					Else
						// Busca pelo nome da cidade caso não encontre pelo codigo.
						nomCidFim := StrTran(nomCidFim,"'") 
						cAliasGU7Fim := GetNextAlias()
						BeginSql Alias cAliasGU7Fim
							SELECT GU7_NRCID , GU7_NMCID, GU7_CDUF
							FROM %Table:GU7% GU7 
							WHERE GU7.GU7_FILIAL = %xFilial:GU7%
							AND Upper(GU7.GU7_NMCID) = Upper(%Exp:nomCidFim%)
							AND Upper(GU7.GU7_CDUF) = Upper(%Exp:nomUFFim%)
							AND GU7.%NotDel%
						EndSql
						If nomCidFim == AllTrim((cAliasGU7Fim)->GU7_NMCID) .Or. Upper(nomCidFim) == AllTrim((cAliasGU7Fim)->GU7_NMCID) 
							nomCidFim  := "'"+AllTrim((cAliasGU7Fim)->GU7_NMCID)+"'"
							nAuxCidFim := (cAliasGU7Fim)->GU7_NRCID
							cAuxUFFim  := (cAliasGU7Fim)->GU7_CDUF
						Else 
							cMsgPreVal := "Cidade Final não cadastrada no Sistema, por favor realize o cadastro da Cidade "+ AllTrim(nomCidFim) +" antes da Importação"
							Return Nil
						EndIf
						(cAliasGU7Fim)->(dbCloseArea())
					EndIf
					(cAliasGU7)->(dbCloseArea())
					
					cNmCidIni := "%("+Capital(nomCidIni)+", "+Lower(nomCidIni)+", "+Upper(nomCidIni)+", "+Capital(FwCutOff(nomCidIni, .T.))+", "+Lower(FwCutOff(nomCidIni, .T.))+", "+Upper(FwCutOff(nomCidIni, .T.))+")%"
					cNmCidFim := "%("+Capital(nomCidFim)+", "+Lower(nomCidFim)+", "+Upper(nomCidFim)+", "+Capital(FwCutOff(nomCidFim, .T.))+", "+Lower(FwCutOff(nomCidFim, .T.))+", "+Upper(FwCutOff(nomCidFim, .T.))+")%"

					cAliasCID := GetNextAlias()
					BeginSql Alias cAliasCID
						SELECT GWU.GWU_SEQ
						FROM %Table:GWU% GWU

						INNER JOIN %Table:GU7% GU7A
						ON GU7A.GU7_FILIAL = %xFilial:GU7%
						AND GU7A.GU7_NMCID IN %Exp:Alltrim(cNmCidIni)%
						AND GU7A.GU7_CDUF = %Exp:Alltrim(nomUFIni)%
						AND GU7A.%NotDel%

						INNER JOIN %Table:GU7% GU7B
						ON GU7B.GU7_FILIAL = %xFilial:GU7%
						AND GU7B.GU7_NMCID IN %Exp:Alltrim(cNmCidFim)%
						AND GU7B.GU7_CDUF = %Exp:Alltrim(nomUFFim)%
						AND GU7B.%NotDel%

						WHERE GWU.GWU_FILIAL = %Exp:aGXH[1][1]%
						AND GWU.GWU_CDTPDC = %Exp:aGXH[1][6]%
						AND GWU.GWU_EMISDC = %Exp:aGXH[1][3]%
						AND GWU.GWU_SERDC = %Exp:aGXH[1][4]%
						AND GWU.GWU_NRDC = %Exp:aGXH[1][5]%
						AND GWU.GWU_CDTRP IN (%Exp:GFEGetEmRz(aGXG[03])%)
						AND GWU.GWU_NRCIDO = GU7A.GU7_NRCID
						AND GWU.GWU_NRCIDD = GU7B.GU7_NRCID
						AND GWU.%NotDel%
					EndSql
					If (cAliasCID)->(!Eof())
						cTPDF := IIf((cAliasCID)->GWU_SEQ == '01','1','6')
					EndIf
					(cAliasCID)->(dbCloseArea())
				EndIf
				(cAliasGWU)->(dbCloseArea())
			EndIf
		EndIf
	EndIf
Return cTPDF

//-------------------------------------------------------------------
/*/{Protheus.doc} A118EMIT

Busca remetente, destinatário ou transportador do CT-e/EDI no cadastro de emitentes do GFE (GU3)

@author Alan Victor Lamb
@since 12/05/2014
@param cTipo  1=Emitente/2=Remetente/3=Destinatário
@param cIDFED  CNPJ Ou CPF do emitente/remetente/destinatário
@param aGXH Array contendo as notas sendo importadas
aGXH[n][1] //GXH_FILDC
aGXH[n][2] //GXH_SEQ
aGXH[n][3] //GXH_EMISDC
aGXH[n][4] //GXH_SERDC
aGXH[n][5] //GXH_NRDC
aGXH[n][6] //GXH_TPDC
aGXH[n][7] //GXH_NFE
aGXH[n][8] //GXH_CNPJEM
@version 1.0
/*/
//-------------------------------------------------------------------
Function A118EMIT(cTipo, cIDFED, aGXH)
Local lFound    := .F.
Local cAliasGW1 := Nil
Local cAliasGWU := Nil
Local cAliasGu3 := Nil
Local cEmit     := ''
Local cVLCNPJ   := SuperGetMV('MV_VLCNPJ',,'1')
Local nRecnoGW1 := 0

Default cIDFED	:= ""
Default aGXH  	:= {}

	// Busca informações de emitentes pelo primeiro documento de carga
	If Len(aGXH) > 0
		// Busca trecho somente com a DANFE
		If !IsInCallStack("GFEA117") .And. !IsInCallStack("GFEA115")
			lFound := BuscaDocTrechoPago(aGXH[1][7],,,,aGXH[1][1],,@nRecnoGW1)
		EndIf

		// Busca trecho com a chave completa
		If !lFound
			lFound := BuscaDocTrechoPago("", aGXH[1][3], aGXH[1][4], aGXH[1][5] ,aGXH[1][1],, @nRecnoGW1)
		EndIf

		// Força a busca por notas fiscais FOB para a importação de ocorrências.
		If IsInCallStack("GFEA117")
			If !lFound
				lFound := BuscaDocTrechoPago(aGXH[1][7],,,,,"2",@nRecnoGW1)
				If !lFound
					lFound := BuscaDocTrechoPago("", aGXH[1][3], aGXH[1][4], aGXH[1][5],,"2",@nRecnoGW1)
				EndIf
			EndIf
		EndIf

		If lFound
			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1.GW1_FILIAL,
						GW1.GW1_CDTPDC,
						GW1.GW1_EMISDC,
						GW1.GW1_SERDC,
						GW1.GW1_NRDC,
						GW1.GW1_CDREM,
						GW1.GW1_CDDEST
				FROM %Table:GW1% GW1
				WHERE GW1.R_E_C_N_O_ = %Exp:nRecnoGW1%
				AND GW1.%NotDel%
			EndSql
			
			If (cAliasGW1)->(!Eof())
				Do Case
					Case cTipo == "1" // 1=Emitente
						// Busca o transportador dos trechos do doc carga com o CNPJ informado no CT-e
						cAliasGWU := GetNextAlias()
						BeginSql Alias cAliasGWU
							SELECT GWU.GWU_CDTRP
							FROM %Table:GWU% GWU
							WHERE GWU.GWU_FILIAL = %Exp:(cAliasGW1)->GW1_FILIAL%
							AND GWU.GWU_CDTPDC = %Exp:(cAliasGW1)->GW1_CDTPDC%
							AND GWU.GWU_EMISDC = %Exp:(cAliasGW1)->GW1_EMISDC%
							AND GWU.GWU_SERDC  = %Exp:(cAliasGW1)->GW1_SERDC%
							AND GWU.GWU_NRDC = %Exp:(cAliasGW1)->GW1_NRDC%
							AND GWU.%NotDel%
						EndSql

						Do While (cAliasGWU)->(!Eof())
							cAliasGU3 := GetNextAlias()
							BeginSql Alias cAliasGU3
								SELECT GU3.GU3_IDFED
								FROM %Table:GU3% GU3
								WHERE GU3.GU3_FILIAL = %xFilial:GU3%
								AND GU3.GU3_CDEMIT = %Exp:(cAliasGWU)->GWU_CDTRP%
								AND GU3.GU3_SIT = '1'
								AND GU3.%NotDel%
							EndSql

							If (cAliasGU3)->(!Eof())
								If AllTrim((cAliasGU3)->GU3_IDFED) == AllTrim(cIDFED)
									cEmit := (cAliasGWU)->GWU_CDTRP
									(cAliasGU3)->(dbCloseArea())
									Exit
								Else
									// Continua procurando pois pode ter um transportador com o mesmo CNPJ em outro trecho
									// Caso não encontre com o CNPJ igual, usará o CNPJ com a mesma raiz
									If cVLCNPJ == "2"
										If SubStr(AllTrim((cAliasGU3)->GU3_IDFED),1,8) == SubStr(AllTrim(cIDFED),1,8)
											cEmit := ValidEmis((cAliasGU3)->GU3_IDFED)
										EndIf
									EndIf
								EndIf
							EndIf

							(cAliasGU3)->(dbCloseArea())
							(cAliasGWU)->(dbSkip())
						EndDo

						(cAliasGWU)->(dbCloseArea())
					Case cTipo == "2" // 2=Remetente
						cEmit := (cAliasGW1)->GW1_CDREM
					Case cTipo == "3" // 3=Destinatário
						cEmit := (cAliasGW1)->GW1_CDDEST
				EndCase
			EndIf

			(cAliasGW1)->(dbCloseArea())
		EndIf
	Else
		If cTipo == "1"
			cEmit := ValidEmis(cIDFED)
		EndIf
	EndIf
Return cEmit
//
// Busca emitente do tipo transportador e ativo na tabela GU3
// cIdFed = CPF ou CNPJ do Emitente
// cMsgTra = Mensagem de Erro
// Ex: ValidEmis(12345678911,"Erro") // Busca por CPF
//
Static Function ValidEmis(cIdFed,cMsgTra,cAuxCodFil)
Local lAchou    := .T.
Local cEmitente := ''
Local cAliasGU3 := Nil

Default cAuxCodFil := xFilial("GU3")

	cMsgTra := ''
	cAliasGU3 := GetNextAlias()
	BeginSql Alias cAliasGU3
		SELECT GU3.GU3_CDEMIT,
				GU3.GU3_TRANSP,
				GU3.GU3_SIT
		FROM %Table:GU3% GU3
		WHERE GU3.GU3_FILIAL = %Exp:cAuxCodFil%
		AND GU3.GU3_IDFED = %Exp:cIdFed%
		AND GU3.%NotDel%
	EndSql

	If (cAliasGU3)->(!EOf())
		lAchou := .F.
		Do While !lAchou .And.(cAliasGU3)->(!Eof())
			lAchou := ((cAliasGU3)->GU3_TRANSP == '1' .And. (cAliasGU3)->GU3_SIT == "1")
			If !lAchou
				// Valida se é transportador GU3_TRANSP
				If !((cAliasGU3)->GU3_TRANSP == '1')
					cMsgTra := "Emitente ("+(cAliasGU3)->GU3_CDEMIT+") não está marcado como transportador no cadastro de emitentes." + CRLF
				EndIf
				// Valida se a situação do emitente está ativa GU3_SIT
				If !((cAliasGU3)->GU3_SIT == '1')
					cMsgTra := "Emitente ("+(cAliasGU3)->GU3_CDEMIT+") não está ativo no cadastro de emitentes." + CRLF
				EndIf
			Else
				cEmitente := (cAliasGU3)->GU3_CDEMIT
				cMsgTra := ""
			EndIf
			(cAliasGU3)->( dbSkip())
		EndDo
	Else
		cMsgTra := "Não encontrado o transportador com CNPJ ("+cIdFed+") no cadastro de emitentes." + CRLF
	EndIf
	(cAliasGU3)->(DbCloseArea())
Return cEmitente
/***********************************************************************************************************
Funçoes para buscar as informações no XML
***********************************************************************************************************/
Static Function CalcVolum()// Carrega os dois campos GXG_VOLUM e GXG_QTVOL com informações do XML
	Local lContinua := .T.
	Local oXml      := Nil
	Local nX        := 0
	Local aPesos    := {0,0,0,0,0} //1-Bruto;2-Cubado;3-Aferido;4-Declarado;5-Aforado

	// Tag _INFCTENORM não existe em arquivos Ct-e de copmlemento de valores e anulação de valores
	If cTpCte $ "1;2"
		lContinua := .F.
	EndIf

	If lContinua
		oXml := oCTe:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ

		If ValType(oXml) == "A"
			For nX := 1 To Len(oXml)

				If oXml[nX]:_CUNID:TEXT == '00' // Volume em M³
					GXG->GXG_VOLUM := SetField(Val(oXml[nX]:_QCARGA:TEXT), "GXG_VOLUM")

				ElseIf oXml[nX]:_CUNID:TEXT == '01' // KG

					If  'BRUTO' $ oXml[nX]:_TPMED:TEXT
						GXG->GXG_PESOR := SetField(Val(oXml[nX]:_QCARGA:TEXT), "GXG_PESOR")
					EndIf

					If 'CUB' $ Upper(oXml[nX]:_TPMED:TEXT)
						GXG->GXG_PESOC := SetField(Val(oXml[nX]:_QCARGA:TEXT), "GXG_PESOC")
					Else
						aPesos[1] := SetField(Val(oXml[nX]:_QCARGA:TEXT) , "GXG_PESOR")
					Endif

				ElseIf oXml[nX]:_CUNID:TEXT == '02' // TON

					If  'BRUTO' $ oXml[nX]:_TPMED:TEXT
						GXG->GXG_PESOR := SetField(Val(oXml[nX]:_QCARGA:TEXT) * 1000, "GXG_PESOR")
					EndIf

					If 'CUB' $ Upper(oXml[nX]:_TPMED:TEXT)
						GXG->GXG_PESOC := SetField(Val(oXml[nX]:_QCARGA:TEXT) * 1000, "GXG_PESOC")
					Else
						aPesos[1] := Val(oXml[nX]:_QCARGA:TEXT) * 1000
					EndIf

				ElseIf oXml[nX]:_CUNID:TEXT == '03' // Unidades
					GXG->GXG_QTVOL := SetField(NoRound(Val(oXml[nX]:_QCARGA:TEXT)), "GXG_VOLUM")
				EndIf

			Next nX

			If Empty(GXG->GXG_PESOR)
				GXG->GXG_PESOR := SetField(aPesos[1], "GXG_PESOR")
			EndIf

		ElseIf ValType(oXml) == "O"

			If oXml:_CUNID:TEXT == '00' // Volume em M³
				GXG->GXG_VOLUM := Val(oXml:_QCARGA:TEXT)

			ElseIf oXml:_CUNID:TEXT == '01' //KG
				If 'CUB' $ Upper(oXml:_TPMED:TEXT)
					GXG->GXG_PESOC := SetField(Val(oXml:_QCARGA:TEXT), "GXG_PESOC")
				EndIf
				GXG->GXG_PESOR := SetField(Val(oXml:_QCARGA:TEXT), "GXG_PESOR")

			ElseIf oXml:_CUNID:TEXT == '02' // TON
				If 'CUB' $ UPPER(oXml:_TPMED:TEXT)
					GXG->GXG_PESOC := SetField(Val(oXml:_QCARGA:TEXT) * 1000, "GXG_PESOC")
				EndIf
				GXG->GXG_PESOR := SetField(Val(oXml:_QCARGA:TEXT) * 1000,"GXG_PESOR")

			ElseIf oXml:_CUNID:TEXT == '03' // Unidades
				GXG->GXG_QTVOL := SetField(NoRound(Val(oXml:_QCARGA:TEXT)), "GXG_VOLUM")
			EndIf
		EndIf
	EndIf
Return

// ----
Static Function SetField(nValor, cCampo, lValid)
Local aTamSX3 := TamSX3(cCampo)
Local cValor  := ''
Local nRet    := 0

Default lValid := .T.

	If Empty(nValor)
		nValor := 0
	EndIf

	cValor := cValToChar(Round(nValor, 0))
	cValor := StrTran(cValor, ".", "")
	cValor := StrTran(cValor, ",", "")

	If aTamSX3[2] > 0
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1]) + "." + Replicate("9", aTamSX3[2])))
	Else
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1])))
	EndIf

	If Len(cValor) > aTamSX3[1]

		If lValid
			cMsgPreVal += "- " + "Erro no campo: " + cCampo + ". Valor '" + cValToChar(nValor) + "' com formato inválido ou não suportado." + CRLF
		EndIf
		cValor := '0'
	EndIf
	nRet := Val(cValor)
Return nRet

Static Function CalcVlCar()
Local nVl := 0

	If XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA','_VCARGA'},'_VCARGA',.T.) == "vCarga"
		nVl := Val(XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA'},'_VCARGA'))
	ElseIf XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA','_VMERC'},'_VMERC',.T.) == "vMerc"
		nVl := Val(XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA'},'_VMERC'))
	Else
		nVl := 0
	EndIf
Return nVl
//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA118MARK

Marcações do browse
@author Ana Claudia da Silva
@since 26/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA118MARK()
Local aAreaGXG  := GetArea()
Local cAliasGXG := Nil

	// Busca alias do próprio browse, que neste caso é a DCF
	cAliasGXG := oBrowse115:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasGXG)->(dbGoTop())
	Do While (cAliasGXG)->(!Eof())
		RecLock("GXG", .F.)
			GXG->GXG_MARKBR := IIf(GXG_MARKBR <> oBrowse115:Mark(),oBrowse115:Mark(),"  ")
		GXG->(MsUnlock())
		(cAliasGXG)->(dbSkip())
	EndDo
	RestArea(aAreaGXG)
	oBrowse115:Refresh(.T.)
Return Nil
/*****************************************************************************************************
Fim Das Validações do XML
*****************************************************************************************************/
// Verifica existência de um índice no dicionário
Static Function ValidSIX(cTab, cOrdem)
Local lRet := .F.

	SIX->(dbSetOrder(1))
	If SIX->(dbSeek(cTab+cOrdem))
		lRet := .T.
	EndIf
Return lRet

Function GFEA118GW3(cChaveCte)
Local aAreaGW3  := GW3->(GetArea())
Local cAliasGW3 := Nil

	If Empty(cChaveCte)
		GFEHelp("Chave do CT-e não informado",,,.F.)
	Else
		cAliasGW3 := GetNextAlias()
		BeginSql Alias cAliasGW3
			SELECT GW3.R_E_C_N_O_ RECNOGW3
			FROM %Table:GW3% GW3
			WHERE GW3.GW3_CTE = %Exp:cChaveCte%
			AND GW3.%NotDel%
		EndSql

		If (cAliasGW3)->(!Eof())
			GW3->(dbGoto((cAliasGW3)->RECNOGW3))
			FWExecView("Visualizar", "GFEC065", 1,, {||.T.})
		Else
			GFEHelp("Não existe o documento de frete com a Chave CT-e " + cChaveCte,,,.F.)
		EndIf
		(cAliasGW3)->(dbCloseArea())
	EndIf
	RestArea(aAreaGW3)
Return

// Consultar documento nas tabelas de Notas fiscais
Static Function ValidCFOP( cDoc, cSerie, cCgcRem, cCgcDest, cNFE)
Local lRet      := .T.
Local lDanfe    := !Empty(cNFE)
Local cAliasSD1 := Nil
Local cAliasSD2 := Nil
Local cFilGW1   := xFilial("GW1")
Local cCFOP     := ""

	If !lDanfe
		If !Empty(cCgcRem)
			//Busca Codigo do Cliente/Fornecedor e da Loja na tabela SA2 do CGCRem
			cAliasSD1 := GetNextAlias()
			BeginSql Alias cAliasSD1
				SELECT SD1.D1_CF
				FROM %Table:SA2% SA2
				INNER JOIN %Table:SF1% SF1
				ON SF1.F1_FILIAL = %Exp:cFilGW1%
				AND SF1.F1_DOC = %Exp:cDoc%
				AND SF1.F1_SERIE = %Exp:cSerie%
				AND SF1.F1_FORNECE = SA2.A2_COD
				AND SF1.F1_LOJA = SA2.A2_LOJA
				AND SF1.%NotDel%
				INNER JOIN %Table:SD1% SD1
				ON SD1.D1_FILIAL = SF1.F1_FILIAL
				AND SD1.D1_DOC = SF1.F1_DOC
				AND SD1.D1_SERIE = SF1.F1_SERIE
				AND SD1.D1_FORNECE = SF1.F1_FORNECE
				AND SD1.D1_LOJA = SF1.F1_LOJA
				AND SD1.%NotDel%
				WHERE SA2.A2_FILIAL = %xFilial:SA2%
				AND SA2.A2_CGC = %Exp:cCgcRem%
				AND SA2.%NotDel%
			EndSql
			cCFOP := (cAliasSD1)->D1_CF
			(cAliasSD1)->(dbCloseArea())
		EndIf
	Else
		cAliasSD1 := GetNextAlias()
		BeginSql Alias cAliasSD1
			SELECT SD1.D1_CF
			FROM %Table:SF1% SF1
			INNER JOIN %Table:SD1% SD1
			ON SD1.D1_FILIAL = SF1.F1_FILIAL
			AND SD1.D1_DOC = SF1.F1_DOC
			AND SD1.D1_SERIE = SF1.F1_SERIE
			AND SD1.D1_FORNECE = SF1.F1_FORNECE
			AND SD1.D1_LOJA = SF1.F1_LOJA
			AND SD1.%NotDel%
			WHERE SF1.F1_FILIAL = %Exp:cFilGW1%
			AND SF1.F1_CHVNFE = %Exp:cNFE%
			AND SF1.%NotDel%
		EndSql
		cCFOP := (cAliasSD1)->D1_CF
		(cAliasSD1)->(dbCloseArea())
	EndIf
	//Se encontrou registro na tabela SF1
	If Empty(cCFOP)
		If !lDanfe
			If !Empty(cCgcDest)
				//Busca Codigo do Cliente/Fornecedor e da Loja na tabela SA2 CGCDEst
				cAliasSD2 := GetNextAlias()
				BeginSql Alias cAliasSD2
					SELECT SD2.D2_CF
					FROM %Table:SA2% SA2
					INNER JOIN %Table:SF2% SF2
					ON SF2.F2_FILIAL = %Exp:cFilGW1%
					AND SF2.F2_DOC = %Exp:cDoc%
					AND SF2.F2_SERIE = %Exp:cSerie%
					AND SF2.F2_CLIENTE = SA2.A2_COD
					AND SF2.F2_LOJA = SA2.A2_LOJA
					AND SF2.%NotDel%
					INNER JOIN %Table:SD2% SD2
					ON SD2.D2_FILIAL = SF2.F2_FILIAL
					AND SD2.D2_DOC = SF2.F2_DOC
					AND SD2.D2_SERIE = SF2.F2_SERIE
					AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
					AND SD2.D2_LOJA = SF2.F2_LOJA
					AND SD2.%NotDel%
					WHERE SA2.A2_FILIAL = %xFilial:SA2%
					AND SA2.A2_CGC = %Exp:cCgcDest%
					AND SA2.%NotDel%
				EndSql
				cCFOP := (cAliasSD2)->D2_CF
				(cAliasSD2)->(dbCloseArea())
			EndIf
		Else
			cAliasSD2 := GetNextAlias()
			BeginSql Alias cAliasSD2
				SELECT SD2.D2_CF
				FROM %Table:SF2% SF2
				INNER JOIN %Table:SD2% SD2
				ON SD2.D2_FILIAL = SF2.F2_FILIAL
				AND SD2.D2_DOC = SF2.F2_DOC
				AND SD2.D2_SERIE = SF2.F2_SERIE
				AND SD2.D2_CLIENTE = SF2.F2_CLIENTE
				AND SD2.D2_LOJA = SF2.F2_LOJA
				AND SD2.%NotDel%
				WHERE SF2.F2_FILIAL = %Exp:cFilGW1%
				AND SF2.F2_CHVNFE = %Exp:cNFE%
				AND SF2.%NotDel%
			EndSql
			cCFOP := (cAliasSD2)->D2_CF
			(cAliasSD2)->(dbCloseArea())
		EndIf
	EndIf
	If !Empty(cCFOP) .And. ValFxCFOP(cCFOP, cFilGW1)
		lRet := .F.
	EndIf
Return lRet
//--------------------------------------------------------------------------
/*/{Protheus.doc} V0alFxCFOP()
Verifica se o CFOP está cadastrado com exceção do GFE com Totvs Colaboração
@version 1.0
@param cCFOP, caracter, código de CFOP do documento
@param cFilCTE, caracter, Filial do documento de carga
@return lRet, logical, .T. CFOP cadastrado nas exceções - .F. CFOP não cadastrado
@example
(examples)
@see (links_or_references)
/*/
//--------------------------------------------------------------------------
Static Function ValFxCFOP(cCFOP, cFilCTE)
Local lRet      := .F.
Local cAliasGZX := GetNextAlias()

	If GFXTB12130("GZX")
		BeginSql Alias cAliasGZX
			SELECT 1
			FROM %Table:GZX% GZX
			WHERE GZX.GZX_FILIAL = %xFilial:GZX%
			AND GZX.GZX_FILCTE = %Exp:cFilCTE%
			AND %Exp:AllTrim(cCFOP)% BETWEEN GZX.GZX_CFOPDE AND GZX.GZX_CFOPAT
			AND GZX.%NotDel%
		EndSql
		lRet := (cAliasGZX)->(!Eof())
		(cAliasGZX)->(dbCloseArea())
	EndIf
Return lRet

//Indica se a forma de recebimento de arquivos de CTe será por TOTVS Colaboração 2.0
Function GA118TC20()
Local lRet          := .F.
Local cTotvsColab	:= SuperGetMV("MV_SPEDCOL", .F., "N")
Local cTotvsCol20	:= Alltrim( SuperGetMv("MV_TCNEW", .F. ,"" ) )

	//Validação de utilização do Totvs Colaboração 2.0
	//A mesma regra existe nos GFEA065/GFEA118/GFEX000.
	//Lógica copiada da função ColabGeneric.prw
	If cTotvsColab == "S" .And. ( ("0" $ cTotvsCol20) .Or. ("6" $ cTotvsCol20)) //0-Todos / 6-Recebimento
		lRet := .T.
	EndIf
Return lRet

Static Function GA118CrDir(cDir)
Local lRet := .T.

	If !ExistDir(cDir)
		If MakeDir(cDir) <> 0
			GFEHelp("Não foi possível criar diretório " + cDir + " (Erro " + cValToChar(FError()) + ").",,,.F.)
			lRet := .F.
		EndIf
	EndIf
Return lRet

//Inclui a barra ('/' ou '\') no fim do diretório, caso haja necessidade.
Static Function GFEA118Bar(cDir)

	Local cBarra := If(isSrvUnix(),"/","\")

	If SubStr(cDir, Len(cDir), 1) != '/' .And. SubStr(cDir, Len(cDir), 1) != '\'
		cDir += cBarra
	EndIf
return cDir
//--------------------------------------------------------------------
/* BuscaDocTrechoPago
Busca o documento de carga que possuir trecho pago em todas filiais.
Reposiciona a GW1 no documento encontrado.

Parâmetros:
cDANFE, cEmisDC, cSerDC, cNrDc e cFilDC (opcional)

Retorno:
lRet Lógico - Encontrou documento
*/
//--------------------------------------------------------------------
Static Function BuscaDocTrechoPago(cDANFE, cEmisDC, cSerDC, cNrDc, cFilDC, cTpFrete, nRecnoGW1)
	Local lRet      := .T.
	Local lGravaLog := IIf(IsInCallStack("GFEA118XML") .And. !IsInCallStack("A118EMIT"), .T., .F.) //Evita gravação de log na leitura de emissor, remetente e destinatário
	Local cAliasGW1 := Nil
	Local cAliasGXP := Nil
	Local cWhere    := ''
	Local cInner    := ''
	Local nCount    := 0
	Local cVLCNPJ   :=  SuperGetMV('MV_VLCNPJ',,'1')

	Default cEmi   	 := ''
	Default cFilDC   := ''
	Default cDANFE   := ''
	Default cEmisDC  := ''
	Default cSerDC   := ''
	Default cNrDc    := ''
	Default cTpFrete := '1'
	Default oCTe 	 := Nil

	RecnoGW1 := 0

	If __lCpoSr == Nil
		__lCpoSr   := TamSX3("GW1_SERDC")[1] == 14
	EndIf

	/*Verificar se há somente um documento com a chave ou número informado. Se houver, este será utilizado.
	Do contrário, faz a regra de buscar o documento com trecho pago e transportador informado. */

	//Cláusula comum aos 2 SQLs
	cWhere :=       " WHERE GW1.D_E_L_E_T_ = ' '"
	If !Empty(cFilDC)
		cWhere +=     " AND GW1.GW1_FILIAL = '" + cFilDC + "'"
	EndIf

	If !Empty(cDANFE)
		cWhere +=     " AND GW1.GW1_DANFE = '" + cDANFE + "'"
	Else
		cWhere +=     " AND GW1.GW1_EMISDC = '" + cEmisDC + "'"
		If __lCpoSr .And. Len(AllTrim(cSerDC)) <= 3
			cWhere += " AND GW1.GW1_SDOC = '" + cSerDC + "'"
		Else
			cWhere += " AND GW1.GW1_SERDC = '" + cSerDC + "'"
		EndIf
		cWhere +=     " AND GW1.GW1_NRDC = '" + cNrDc + "'"
	EndIf
	cWhere := "%"+cWhere+"%"

	//Contagem de documentos de carga
	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT COUNT(*) GW1_COUNT
		FROM %Table:GW1% GW1
		%Exp:cWhere%
	EndSql

	If lGravaLog
		GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com mesmo número. SQL: [" + GetLastQuery()[2] + "]")
	EndIf
	nCount := (cAliasGW1)->GW1_COUNT
	(cAliasGW1)->(dbCloseArea())

	If nCount == 0

		cAliasGXP := GF115GXPDC(cEmisDC, cSerDC, cNrDc, cFilDC, cDANFE)

		If (cAliasGXP)->(Eof()) .Or. Empty((cAliasGXP)->R_E_C_N_O_)
			If lGravaLog
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com mesmo número não encontrou registro.")
			EndIf

			lRet := .F.
		Else
			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1.R_E_C_N_O_ RECNOGW1
				FROM %Table:GW1% GW1
				WHERE GW1.R_E_C_N_O_ = %Exp:(cAliasGXP)->R_E_C_N_O_%
				AND GW1.%NotDel%
			EndSql

			If (cAliasGW1)->(!Eof())
				nRecnoGW1 := (cAliasGW1)->RECNOGW1
			EndIf
			(cAliasGW1)->(dbCloseArea())
			lRet := .T.

		EndIf
		(cAliasGXP)->(dbCloseArea())

		// Pesquisa o Documento de Carga usando a Série sem zeros à esquerda.
		// Isso visa contornar o caso específico, por exemplo, no qual o Documento está gravado com Série '1',
		// e o XML está gravado como '01'
		If !lRet .And. ( cSerDC != cValToChar(Val(cSerDC)) )
			cSerDC := cValToChar(Val(cSerDC))
			lRet := BuscaDocTrechoPago(cDANFE, cEmisDC, cSerDC, cNrDc, cFilDC, cTpFrete,@nRecnoGW1)
		EndIf

	ElseIf nCount == 1

		cInner := "'1'"
		IF cVLCNPJ == "2" .And. !Empty(cEmi)
			cEmit := GFEGetEmRz(cEmi)
			If SubStr(AllTrim(cEmit),1,8) == SubStr(AllTrim(cEmi),1,8)
				cInner += " AND GWU.GWU_CDTRP IN ('" + Alltrim(cEmit) + "')"
			EndIf
		Else
			If !Empty(cEmi)
				cInner += " AND GWU.GWU_CDTRP = '" + Alltrim(cEmi) + "'"
			EndIf
		EndIf
		cInner := "%" + cInner + "%" 

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.GW1_FILIAL,
					GW1.R_E_C_N_O_ RECNOGW1
			FROM %Table:GW1% GW1
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.GWU_PAGAR = %Exp:cInner%
			AND GWU.%NotDel%
			%Exp:cWhere%
		EndSql

		If (cAliasGW1)->(!Eof())
			lRet      := .T.
			nRecnoGW1 := (cAliasGW1)->RECNOGW1

			If lGravaLog
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com mesmo número encontrou 1 registro. Filial: " + (cAliasGW1)->GW1_FILIAL)
			EndIf
		Else
			lRet := .F.
			If lGravaLog
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com trecho pago e transportador informado não encontrou registro.")
			EndIf
		EndIf
		(cAliasGW1)->(dbCloseArea())
	Else
		//Verificação da filial que possui o documento de carga com trecho pago e transportador informado.

		If lGravaLog
			GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com mesmo número encontrou mais de 1 registro.")
		EndIf

		cInner := "'" + cTpFrete + "'"
		
		If !Empty(cEmi)
			IF cVLCNPJ == "2"
				cEmit := GFEGetEmRz(cEmi)
				
				cInner += " AND GWU.GWU_CDTRP IN ('" + Alltrim(cEmit) + "')"
			Else
				cInner += " AND GWU.GWU_CDTRP = '" + Alltrim(cEmi) + "'"
			EndIf
		Else
			cInner += " AND GWU.GWU_CDTRP <> ' '"
		EndIf

		cInner := "%" + cInner + "%"

		cAliasGW1 := GetNextAlias()
		BeginSql Alias cAliasGW1
			SELECT GW1.GW1_FILIAL,
					GW1.R_E_C_N_O_ RECNOGW1
			FROM %Table:GW1% GW1
			INNER JOIN %Table:GWU% GWU
			ON GWU.GWU_FILIAL = GW1.GW1_FILIAL
			AND GWU.GWU_CDTPDC = GW1.GW1_CDTPDC
			AND GWU.GWU_EMISDC = GW1.GW1_EMISDC
			AND GWU.GWU_SERDC = GW1.GW1_SERDC
			AND GWU.GWU_NRDC = GW1.GW1_NRDC
			AND GWU.GWU_PAGAR  = %Exp:cInner%
			AND GWU.%NotDel%
			%Exp:cWhere%
			ORDER BY GW1.GW1_DTEMIS DESC
		EndSql
		If lGravaLog
			GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com trecho pago e transportador informado. SQL: [" + GetLastQuery()[2] + "]")
		EndIf

		If (cAliasGW1)->(!Eof())
			If lGravaLog
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com trecho pago e transportador informado. Filial: " + (cAliasGW1)->GW1_FILIAL)
			EndIf

			nRecnoGW1 := (cAliasGW1)->RECNOGW1

			// Valida se o documento listado possui o transportador do trecho igual ao emitente do CTe
			While (cAliasGW1)->(!Eof())
				GW1->(dbGoTo((cAliasGW1)->RECNOGW1))
				If GWU->(dbSeek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC) .And. !Empty(GWU->GWU_CDTRP))
					While GWU->(!Eof()) .And. GWU->GWU_FILIAL==GW1->GW1_FILIAL .And. GWU->GWU_CDTPDC==GW1->GW1_CDTPDC .And. GWU->GWU_EMISDC==GW1->GW1_EMISDC .And. GWU->GWU_SERDC==GW1->GW1_SERDC .And. GWU->GWU_NRDC==GW1->GW1_NRDC
						cCnpjTran := Posicione("GU3", 1, xFilial("GU3") + GWU->GWU_CDTRP, "GU3_IDFED")
						If ValType(oCTe)=="O" 
							IF cVLCNPJ == "2"
								If SubStr(Alltrim(cCnpjTran),1,8) == SubStr(Alltrim(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ")),1,8)
									nRecnoGW1 := (cAliasGW1)->RECNOGW1
								EndIf
							Else
								If Alltrim(cCnpjTran) == Alltrim(XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ"))
									nRecnoGW1 := (cAliasGW1)->RECNOGW1
								EndIf
							EndIf
						EndIf

						GWU->(dbSkip())   
					EndDo
				EndIf

				(cAliasGW1)->(DbSkip())
			Enddo

			lRet := .T.
		Else
			//Apesar de encontrar mais de um documento, pode ser que em ambas as filiais estejam com transportador em branco ou tipo de frete não pago.
			If lGravaLog
				GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + " - Busca documento com trecho pago e transportador informado não encontrou registro.")
			EndIf

			lRet := .F.
		EndIf
		(cAliasGW1)->(dbCloseArea())
	EndIf
Return lRet
//--------------------------------------------------------------------
/* GA118ExtDirOrFileName
Extrai o nome do arquivo de um caminho completo
Parâmetros:
Char: caminho completo do arquivo
Number: indica se retornará o caminho (1) ou o nome do arquivo (2).
Retorno:
Char: nome do arquivo
*/
//--------------------------------------------------------------------
Static Function GA118ExtDirOrFileName(cFile,nRet)
	Local nPos := 0
	Local lIsLinux  := IsSrvUnix()

	nPos := RAt(IIf(lIsLinux, '/', '\'), cFile)
	If nPos > 0
		If nRet = 1
			cFile := Substr(cFile, 1, nPos)
		Else
			cFile := Substr(cFile, nPos+1, Len(cFile))
		EndIf
	ElseIf lIsLinux
		nPos := RAt('\', cFile)
		If nPos > 0
			If nRet = 1
				cFile := Substr(cFile, 1, nPos)
			Else
				cFile := Substr(cFile, nPos+1, Len(cFile))
			EndIf
		EndIf
	EndIf
Return cFile
/*-------------------------------------------------------------------
{Protheus.doc} GFEA118MKT
Selecionar Todos

@author Ana Claudia da Silva
@since 22/02/2016
@version 1.0
-------------------------------------------------------------------  */
Function GFEA118MKT()
	Local aAreaGXG  := GetArea()
	Local cAliasGXG := Nil
	Private cFilter := ""

	cAliasGXG := oBrowse115:Alias()
	// Ao executar o comando DbGoTop(), o sistema re-executa todos os filtros e, desta forma,
	// a regra de marcação será executada apenas para os registros que o usuário vê em tela
	(cAliasGXG)->(dbGoTop())
	ActiveFilters(oBrowse115)
	(cAliasGXG)->(dbSetFilter({|| &(cFilter) }, cFilter))
	oBrowse115:Refresh(.T.)
	
	Do While (cAliasGXG)->(!Eof())
		If (GXG->GXG_MARKBR <> oBrowse115:Mark()) 
			RecLock("GXG", .F.)
				GXG->GXG_MARKBR := oBrowse115:Mark()
			GXG->(MsUnlock())
		EndIf
		(cAliasGXG)->(dbSkip())
	EndDo
	RestArea(aAreaGXG)
	oBrowse115:Refresh(.T.)
Return Nil

//--------------------------------------------------------------------
/*{Protheus.doc} ActiveFilters()
Função para verificar os filtros ativados do browse
@param   oBrowse - Indica oBrowse no momento que a função é chamada
@return  cFilter - Indica a consulta AdvPL para realizar através do dbSetFilter()
@author  Philippe Bretas
@since   24/04/2025
@version 1.0
*/
//--------------------------------------------------------------------
Static Function ActiveFilters(oBrowse)

	Local lenFilter  := len(oBrowse:oBrowse:oFwFilter:afilter)
	Local lFilter  	 := .F. 
	Local aActFilter := {} 
	Local cVar  	 := "" 
	Local cOp		 := "" 
	Local cVal 	  	 := "" 
	Local nZ	 	 := Nil	
	Local nX 	   	 := Nil

	For nX := 1 to lenFilter		
		lFilter := oBrowse:oBrowse:oFwFilter:afilter[nx][6]
		If lFilter == .T. .And. !Empty(oBrowse115:oBrowse:oFwFilter:afilter[nX][4])
	        cVar := oBrowse:oBrowse:oFwFilter:afilter[nX][4][1][1] + ' '
			cOp  := oBrowse:oBrowse:oFwFilter:afilter[nX][4][2][1] + ' '
			cVal := oBrowse:oBrowse:oFwFilter:afilter[nX][4][3][1]

			Do Case 
                Case ValType(cVal) == "D"
                    cVal := "'" + Dtos(cVal) + "'"
                Case ValType(cVal) == "N"
                    cVal := "'" + Transform(cVal, "@E") + "'"
                Otherwise
                    cVal := "'" + cVal + "'"
            EndCase

			AADD(aActFilter, cVar + cOp + cVal)
		ElseIf  lFilter == .T. 
			AADD(aActFilter, oBrowse:GetFilterDefault())
		EndIf
	Next

	For nZ := 1 to len(aActFilter)	
		If nZ != len(aActFilter)
			cFilter += aActFilter[nZ] + ".And. "
		Else
			cFilter += aActFilter[nZ]
		EndIf
	Next
Return  cFilter

//--------------------------------------------------------------------
/* GA118MoveFile
Move para um diretório destino.
Grava no log os textos.

Retorno:
Boolean: indica se a exclusão foi efetuada com sucesso
*/
//--------------------------------------------------------------------
Static Function GA118MoveFile(cOrigem, cDestino, GFELog118)
	Local lRet    := .T.
	Local nFError := 1

	//Só pode eliminar o arquivo caso consiga copiá-lo para pasta destino.
	IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Tentativa de cópia do arquivo da pasta ' + GA118ExtDirOrFileName(cOrigem,1) + ' para ' + GA118ExtDirOrFileName(cDestino,1) + '.'), '')
	Copy File &(cOrigem) To &(cDestino)

	nFError := FError()
	If nFError == nil
		nFError := 1
	EndIf

	If nFError <> 0
		lRet := __CopyFile(cOrigem, cDestino,,,.T.)
		If !lRet
			IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Erro ao copiar arquivo (' + Alltrim(STR(nFError)) + ') ' + GFERetFError(nFError) + '.' ), '')
		Else
			IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Cópia efetuada com sucesso.'), '')
		EndIf
	Else
		IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Cópia efetuada com sucesso.'), '')

		If File(cDestino)
			IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Arquivo ' + cDestino + ' encontrado.'), '')
		Else
			IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Arquivo ' + cDestino + ' não encontrado.'), '')
		EndIf

		IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Tentativa de exclusão do arquivo da pasta ' + GA118ExtDirOrFileName(cOrigem,1) + '.'), '')
		If FErase(cOrigem) == -1
			IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Erro ao excluir arquivo (' + STR(FERROR()) + ') ' + GFERetFError(FError()) + '.'), '')
			lRet := .F.
		Else
			IIf (GFELog118 <> nil, GFELog118:Add(GFENOW(.F.,,,':','.') + SB6 + ' - Exclusão efetuada com sucesso.'), '')
		EndIf
	EndIf
Return lRet

Function GFERetFError(nError)
	Do Case
	Case nError == 0
		cError := "Operation sucess"
	Case nError == 1
		cError := "(Unexpected Error Code)"
	Case nError == 2
		cError := "Unix : Path/File not found"
	Case nError == 3
		cError := "(Unexpected Error Code)"
	Case nError == 4
		cError := "Unix : Bad File Descriptor"
	Case nError == 13
		cError := "Win / Unix : Access is denied."
	Case nError == 24
		cError := "Win : The local device name is already in use."
	Case nError == 25
		cError := "Win : Attempt to create file that already exists."
	Case nError == 158
		cError := "Win : The file or directory is damaged and nonreadable."
	Case nError == 159
		cError := "Win / Unix : The file exists."
	Case nError == 160
		cError := "Win / Unix : The volume for a file was externally altered and the opened file is no longer valid."
	Case nError == 161
		cError := "Win / Unix : The system cannot find the file specified."
	Case nError == 163
		cError := "Win / Unix : The file name or extension is too long."
	Otherwise
		cError := "Operation failed or undefined error"
	EndCase
Return cError
//-------------------------------------------------------------------
/*/{Protheus.doc} TelaWiz()
Cria tela de wizard de importação
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpExpMng(cDirXML,cDirLido,cDirErro)
	Local lRet      := .T.
	Local oNewPage  := Nil
	Local oStepWiz  := Nil

	oStepWiz  := FWWizardControl():New()  //Instancia a classe FWWizard
	oStepWiz:ActiveUISteps()
	//------------------------------------------------------------
	// Página 1 - Importar Tabela de Frete
	//------------------------------------------------------------
	oNewPage := oStepWiz:AddStep("1")
	oNewPage:SetStepDescription("Importar CT-e")
	oNewPage:SetConstruction({|Panel, nId |CriarPg(Panel, 1, @cDirXML,@cDirLido,@cDirErro)})
	oNewPage:SetNextAction({|| ValidaArq(cDirXML,cDirLido,cDirErro)})
	oNewPage:SetCancelAction({|| Alert("Cancelado Pelo Usuário"), lRet := .F., .T.})
	//------------------------------------------------------------
	// Página 2 - Confirma
	//------------------------------------------------------------
	oNewPage := oStepWiz:AddStep("2")
	oNewPage:SetStepDescription("Confirmar")
	oNewPage:SetConstruction({|Panel, nId | CriarPg(Panel, 2,@cDirXML,@cDirLido,@cDirErro)})
	oNewPage:SetNextAction({|| .T.})
	oNewPage:SetCancelAction({|| Alert("Cancelado Pelo Usuário"), lRet := .F., .T.})

	oStepWiz:Activate()
	oStepWiz:Destroy()
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} CriarPg(oPanel, nId)
Cria páginas do wizard
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CriarPg(oPanel, nId , cTargetXML, cTargetLido, cTargetErro)
	Local oTGet1    as object
	Local oTGet2    as object
	Local oTGet3    as object
	Local oTButton1 as object
	Local oTButton2 as object
	Local oTSay1    as object
	Local oTSay2    as object
	Local oTSay3    as object

	cTargetXML  += Space( 100 - (Len( AllTrim(cTargetXML))))
	cTargetLido += Space( 100 - (Len( AllTrim(cTargetLido))))
	cTargetErro += Space( 100 - (Len( AllTrim(cTargetErro))))

	If nId == 1

		oTSay1    := TSay():New(40,10,{||"Diretório Importação: "},oPanel,,,,,,.T.,,,200,20)
		oTButton1 := TButton():New(050.5,248,"Pesquisar",oPanel,{||cTargetXML := BuscaDir()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTGet1    := TGet():New(50,10,{|u| If( PCount() > 0, cTargetXML := u, cTargetXML ) } ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTargetXML,,,, )

		oTSay2    := TSay():New(90,10,{||"Diretório Backup OK: "},oPanel,,,,,,.T.,,,200,20)
		oTButton2 := TButton():New(100.5,248,"Pesquisar",oPanel,{||cTargetLido := BuscaDir()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTGet2    := TGet():New(100,10,{|u| If( PCount() > 0, cTargetLido := u, cTargetLido ) } ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTargetLido,,,, )

		oTSay3    := TSay():New(140,10,{||"Diretório Backup NOK: "},oPanel,,,,,,.T.,,,200,20)
		oTButton3 := TButton():New(150.5,248,"Pesquisar",oPanel,{||cTargetErro := BuscaDir()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTGet3    := TGet():New(150,10,{|u| If( PCount() > 0, cTargetErro := u, cTargetErro ) } ,oPanel,230,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTargetErro,,,, )

	ElseIf nId == 2

		oTSay4    := TSay():New(70,10,{||"Confirma importação dos Documentos de Frete? Diretório XML: "},oPanel,,,,,,.T.,,,200,20)
		oTSay5    := TSay():New(90,10,{||"" + cTargetXML + ""},oPanel,,,,,,.T.,,,300,30)
	EndIf
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaArq(cTarget)
Valida arquivo
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidaArq(cTarget,cLog,cErro)
	Local lRet := .T.

	If !GA118CrDir(cTarget)
		lRet := .F.
	EndIf
	If lRet .And. !GA118CrDir(cLog)
		lRet := .F.
	EndIf
	If lRet .And. !GA118CrDir(cErro)
		lRet := .F.
	EndIf
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaDir()
Busca diretório
@author  Lucas Briesemeister
@since   04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function BuscaDir()
	Local cTarget as char

	cTarget := ALLTRIM(cGetFile(,"Diretório ",1,"",.T.,nOR(GETF_LOCALHARD,GETF_RETDIRECTORY) ,.T.,.T.))
Return cTarget
//-------------------------------------------------------------------
/*/{Protheus.doc} ValChaveDoc()
Valida se a chave ou documento foram informados no XML
@author  Squad GFE
@since   08/05/2020
@version 1.0
/*/
//----------------------------------------------------------------n	---
Static Function ValChaveDoc(oInfDoc)
	Local lChvDoc := .F.
	Local nI      := 0
	Local nF      := 0
	Local xINFNFE := XmlChildEx(oInfDoc,"_INFNFE")
	Local xINFNF  := XmlChildEx(oInfDoc,"_INFNF")
	Local xINFOUT := XmlChildEx(oInfDoc,"_INFOUTROS")

	If ValType(xINFNFE) $ "O|A"
		If ValType(xINFNFE) == "A"
			nF := Len(xINFNFE)
			If XmlChildEx(oInfDoc:_INFNFE[1]:_CHAVE,"TEXT") != Nil
				For nI := 1 To nF
					lChvDoc := !Empty(XmlChildEx(oInfDoc:_INFNFE[nI]:_CHAVE,"TEXT"))
					If !lChvDoc
						Exit
					EndIf
				Next nI
			EndIf
		ElseIf ValType(xINFNFE) == "O"
			If XmlChildEx(oInfDoc:_INFNFE,"_CHAVE") != Nil
				lChvDoc := !Empty(XmlChildEx(oInfDoc:_INFNFE:_CHAVE,"TEXT"))
			EndIf
		EndIf
	ElseIf ValType(xINFNF) $ "O|A"
		If ValType(xINFNF) == "A"
			nF := Len(xINFNF)
			If XmlChildEx(oInfDoc:_INFNF[1]:_NDOC,"TEXT") != Nil
				For nI := 1 To nF
					lChvDoc := !Empty(XmlChildEx(oInfDoc:_INFNF[nI]:_NDOC,"TEXT"))
					If !lChvDoc
						Exit
					EndIf
				Next nI
			EndIf
		ElseIf ValType(xINFNF) == "O"
			If XmlChildEx(oInfDoc:_INFNF,"_NDOC") != Nil
				lChvDoc := !Empty(XmlChildEx(oInfDoc:_INFNF:_NDOC,"TEXT"))
			EndIf
		EndIf
	ElseIf ValType(xINFOUT) $ "O|A"
		If ValType(xINFOUT) == "A"
			If XmlChildEx(oInfDoc:_INFOUTROS,"_NDOC") != Nil .Or. XmlChildEx(oInfDoc:_INFOUTROS[1],"_NDOC") != Nil
				nF := Len(xINFOUT)
				For nI := 1 To nF
					lChvDoc := !Empty(XmlChildEx(oInfDoc:_INFOUTROS[nI]:_NDOC,"TEXT"))
					If !lChvDoc
						Exit
					EndIf
				Next nI
			EndIf
		ElseIf ValType(xINFOUT) == "O"
			If XmlChildEx(oInfDoc:_INFOUTROS,"_NDOC") != Nil
				lChvDoc := !Empty(XmlChildEx(oInfDoc:_INFOUTROS:_NDOC,"TEXT"))
			EndIf
		EndIf
	EndIf
Return lChvDoc

Static Function GFE118TAX(cNrDF, cNome, cValor)


	GZZ->( dbSetOrder(1) )
	If !GZZ->( dbSeek(PADR(alltrim(aGXG[01]),TamSx3("GZZ_FILIAL")[1]) + PADR(alltrim(aGXG[02]),TamSx3("GZZ_CDESP")[1]) + PADR(alltrim(aGXG[03]),TamSx3("GZZ_EMISDF")[1]) + PADR(alltrim(aGXG[04]),TamSx3("GZZ_SERDF")[1]) + PADR(alltrim(cNrDF),TamSx3("GZZ_NRDF")[1]) + dtos(aGXG[06]) + PADR(alltrim(UPPER(cNome)),TamSx3("GZZ_TAXA")[1]) ))

		RecLock("GZZ",.T.)
		GZZ->GZZ_FILIAL  :=	aGXG[01]
		GZZ->GZZ_CDESP   :=	aGXG[02]
		GZZ->GZZ_EMISDF  :=	aGXG[03]
		GZZ->GZZ_SERDF   :=	aGXG[04]
		GZZ->GZZ_NRDF    :=	cNrDF
		GZZ->GZZ_DTEMIS  :=	aGXG[06]
		GZZ->GZZ_TAXA    := UPPER(cNome)
		GZZ->GZZ_VALOR   := val(cValor)
		GZZ->(MsUnLock())
	Endif

Return .T.

Function GFEA118PV(oModel)
	Local nOp := oModel:GetOperation()
	Local cNrDF := ""
	Local cGXGFilDc  := oModel:GetModel("GFEA118_GXG"):GetValue("GXG_FILDOC")
	Local cGXGCdEsp  := oModel:GetModel("GFEA118_GXG"):GetValue("GXG_CDESP")
	Local cGXGEmisDF := oModel:GetModel("GFEA118_GXG"):GetValue("GXG_EMISDF")
	Local cGXGSerDF  := oModel:GetModel("GFEA118_GXG"):GetValue("GXG_SERDF")
	Local cGXGNrDF   := oModel:GetModel("GFEA118_GXG"):GetValue("GXG_NRDF")
	Local dGXGDtEmis := oModel:GetModel("GFEA118_GXG"):GetValue("GXG_DTEMIS")

	If nOp == MODEL_OPERATION_UPDATE

		if GFXCP12131("GZZ_NRDF")

			if cGXGFilDc != GXG->GXG_FILDOC .or. ;
					cGXGCdEsp != GXG->GXG_CDESP .or. ;
					cGXGEmisDF != GXG->GXG_EMISDF .or. ;
					cGXGSerDF != GXG->GXG_SERDF .or. ;
					cGXGNrDF != GXG->GXG_NRDF .or. ;
					dGXGDtEmis != GXG->GXG_DTEMIS

				cNrDF := GFE118ZRGW3(ALLTRIM(cGXGNrDF), cGXGCdEsp)

				cQueryGZZ := " SELECT GZZ.R_E_C_N_O_ RECNOGZZ, GZZ_FILIAL, GZZ_CDESP, GZZ_EMISDF, GZZ_SERDF, GZZ_NRDF, GZZ_DTEMIS"
				cQueryGZZ += "   FROM "+RetSqlName('GZZ')+" GZZ"
				cQueryGZZ += "  WHERE GZZ_FILIAL = '" + GXG->GXG_FILDOC + "'"
				cQueryGZZ += "    AND GZZ_CDESP = '" + GXG->GXG_CDESP + "'"
				cQueryGZZ += "    AND GZZ_EMISDF = '" + GXG->GXG_EMISDF+ "'"
				cQueryGZZ += "    AND GZZ_SERDF  = '" + GXG->GXG_SERDF  + "'"
				cQueryGZZ += "    AND GZZ_NRDF   = '" + GXG->GXG_NRDF  + "'"
				cQueryGZZ += "    AND GZZ_DTEMIS   = '" + DTOS(GXG->GXG_DTEMIS)  + "'"
				cQueryGZZ += "    AND D_E_L_E_T_ = ' '"
				cQueryGZZ := ChangeQuery(cQueryGZZ)
				cAliasGZZ := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQueryGZZ),cAliasGZZ,.F.,.T.)

				While (cAliasGZZ)->(!EoF())

					GZZ->(dbGoTo((cAliasGZZ)->RECNOGZZ))
					RecLock("GZZ",.F.)
					GZZ->GZZ_FILIAL := cGXGFilDc
					GZZ->GZZ_CDESP  := cGXGCdEsp
					GZZ->GZZ_EMISDF := cGXGEmisDF
					GZZ->GZZ_SERDF  := cGXGSerDF
					GZZ->GZZ_NRDF   := cNrDF
					GZZ->GZZ_DTEMIS := dGXGDtEmis

					GZZ->(MsUnLock("GZZ"))

					(cAliasGZZ)->(dbskip())
				EndDo
				(cAliasGZZ)->(dbCloseArea())
			Endif
		EndIf
	Endif

	If nOp == MODEL_OPERATION_DELETE

		if GFXCP12131("GZZ_NRDF") .And. GXG->GXG_EDISIT != "4"

			cNrDf := GFE118ZRGW3(ALLTRIM(GXG->GXG_NRDF), GXG->GXG_CDESP)

			dbSelectArea("GZZ")
			GZZ->(dbSetOrder(1))
			GZZ->(dbSeek(GXG->GXG_FILDOC + GXG->GXG_CDESP + GXG->GXG_EMISDF + GXG->GXG_SERDF + GXG->GXG_NRDF + DTOS(GXG->GXG_DTEMIS)))
			While !GZZ->( Eof() ) .And. GZZ->GZZ_FILIAL == GXG->GXG_FILDOC .And. GZZ->GZZ_CDESP == GXG->GXG_CDESP ;
					.AND. GZZ->GZZ_EMISDF == GXG->GXG_EMISDF .And. GZZ->GZZ_SERDF == GXG->GXG_SERDF ;
					.AND. GZZ->GZZ_NRDF == GXG->GXG_NRDF .And. DTOS(GZZ->GZZ_DTEMIS) == DTOS(GXG->GXG_DTEMIS)


				RecLock("GZZ",.F.)
				dbDelete()
				GZZ->(MsUnLock("GZZ"))

				GZZ->( dbSkip() )
			EndDo
		EndIF
	EndIf

Return .T.

Static Function GFE118ZRGW3(cNrDf,cCdEsp)

	Local nQtAlg := 0

	GVT->( dbSetOrder(1) )
	If GVT->( dbSeek(FWxFilial("GVT") + cCdEsp))

		nQtAlg := Iif(GVT->GVT_QTALG > 0, GVT->GVT_QTALG, TamSX3("GW3_NRDF")[1])

		// Zeros ? esquerda = 2 - Retirar ou 3 - Preencher
		If GVT->GVT_ZEROS $ "2|3"
			cNrDF := GFEZapZero(cNrDF)
			If GVT->GVT_ZEROS == "3" .And. Len(cNrDF) < nQtAlg
				cNrDF := PadL(cNrDF, nQtAlg, "0")
			EndIf
		EndIf
	EndIf

Return cNrDF


Static Function GFE118CTE(cChaveRel)

	Local cFilGW1    := ''
	Local nCont      := 1
	Local lFindGW1   := .F.
	Local cAliasDT6  := Nil
	Local cAliasGWE  := Nil
	Local cMsg       := ""

	//Busca o CTE anterior para poder relacionar as notas
	cAliasGW1 := GetNextAlias()
	BeginSql Alias cAliasGW1
		SELECT GW1.GW1_FILIAL,
				GW1.GW1_EMISDC,
				GW1.GW1_SERDC,
				GW1.GW1_NRDC,
				GW1.GW1_CDTPDC,
				GW1.GW1_DANFE,
				GU3.GU3_IDFED
		FROM %Table:GW3% GW3
		INNER JOIN %Table:GW4% GW4
		ON GW4.GW4_FILIAL = GW3.GW3_FILIAL
		AND GW4.GW4_EMISDF = GW3.GW3_EMISDF
		AND GW4.GW4_CDESP = GW3.GW3_CDESP
		AND GW4.GW4_SERDF = GW3.GW3_SERDF
		AND GW4.GW4_NRDF = GW3.GW3_NRDF
		AND GW4.%NotDel%
		INNER JOIN %Table:GW1% GW1
		ON GW1.GW1_FILIAL = GW4.GW4_FILIAL
		AND GW1.GW1_CDTPDC = GW4.GW4_TPDC
		AND GW1.GW1_EMISDC = GW4.GW4_EMISDC
		AND GW1.GW1_SERDC = GW4.GW4_SERDC
		AND GW1.GW1_NRDC = GW4.GW4_NRDC
		AND GW1.%NotDel%
		INNER JOIN %Table:GU3% GU3
		ON GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
		AND GU3.GU3_SIT = '1'
		AND GU3.%NotDel%
		WHERE GW3.GW3_CTE = %Exp:cChaveRel%
		AND GW3.%NotDel%
	EndSql
	If (cAliasGW1)->(!Eof())

		Do While (cAliasGW1)->(!Eof())

			lFindGW1 := .T.

			aAdd(aGXH, {(cAliasGW1)->GW1_FILIAL,;
				Alltrim(STR(nCont)),;
				(cAliasGW1)->GW1_EMISDC, ;
				(cAliasGW1)->GW1_SERDC,;
				(cAliasGW1)->GW1_NRDC,;
				(cAliasGW1)->GW1_CDTPDC,;
				(cAliasGW1)->GW1_DANFE,;
				(cAliasGW1)->GU3_IDFED})

			cFilGW1 := (cAliasGW1)->GW1_FILIAL
			nCont ++
			(cAliasGW1)->(dbSkip())
		EndDo
	Elseif SuperGetMV("MV_TMS3GFE",,"N") != 'N' // Integração TMS Habilitada

		cAliasDT6 := GetNextAlias()
		BeginSql Alias cAliasDT6
			SELECT DT6.DT6_CHVCTE, 
					DT6.DT6_FILDOC, 
					DT6.DT6_DOC, 
					DT6.DT6_SERIE
			FROM %Table:DT6% DT6
			WHERE DT6.DT6_CHVCTE = %Exp:cChaveRel%
			AND DT6.%NotDel%
		EndSql
		If (cAliasDT6)->(!Eof())

			cAliasGWE := GetNextAlias()
			BeginSql Alias cAliasGWE
				SELECT GW1.GW1_FILIAL,
						GW1.GW1_EMISDC,
						GW1.GW1_SERDC,
						GW1.GW1_NRDC,
						GW1.GW1_CDTPDC,
						GW1.GW1_DANFE,
						GU3.GU3_IDFED												
				FROM %Table:GW1% GW1
				INNER JOIN %Table:GWE% GWE
				ON GW1.GW1_FILIAL = GWE.GWE_FILIAL
				AND GW1.GW1_CDTPDC = GWE.GWE_CDTPDC
				AND GW1.GW1_EMISDC = GWE.GWE_EMISDC
				AND GW1.GW1_SERDC  = GWE.GWE_SERDC
				AND GW1.GW1_NRDC   = GWE.GWE_NRDC
				INNER JOIN %Table:GU3% GU3
				ON GU3.GU3_FILIAL = %xFilial:GU3%
				AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
				AND GU3.GU3_SIT = '1'
				AND GU3.%NotDel%													
				WHERE GWE.GWE_FILDT = %Exp:(cAliasDT6)->DT6_FILDOC%
				AND GWE.GWE_NRDT  = %Exp:(cAliasDT6)->DT6_DOC%
				AND GWE.GWE_SERDT = %Exp:(cAliasDT6)->DT6_SERIE%									
				AND GWE.D_E_L_E_T_ = ''
				AND GW1.D_E_L_E_T_ = ''

			EndSql
			If (cAliasGWE)->(!Eof())
				Do While (cAliasGWE)->(!Eof())

					lFindGW1 := .T.

					aAdd(aGXH, {(cAliasGWE)->GW1_FILIAL,;
						Alltrim(STR(nCont)),;
						(cAliasGWE)->GW1_EMISDC, ;
						(cAliasGWE)->GW1_SERDC,;
						(cAliasGWE)->GW1_NRDC,;
						(cAliasGWE)->GW1_CDTPDC,;
						(cAliasGWE)->GW1_DANFE,;
						(cAliasGWE)->GU3_IDFED})

					cFilGW1 := (cAliasGWE)->GW1_FILIAL
					nCont ++
					(cAliasGWE)->(dbSkip())
				EndDo
			EndIF
			(cAliasGWE)->(dbCloseArea())

		EndIF
		(cAliasDT6)->(dbCloseArea())
	ENDIF
	IF !lFindGW1 // Não encontrou documento de carga
		cMsg += "- Documento de frete não encontrado, logo não é possivel relacionar o Documento de Carga. Chave documento anterior: " + cChaveRel + CRLF
	EndIf
	(cAliasGW1)->(dbCloseArea())

Return {lFindGW1, cFilGW1, cMsg}
