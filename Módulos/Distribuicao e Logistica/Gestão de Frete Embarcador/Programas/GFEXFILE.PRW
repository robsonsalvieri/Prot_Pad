#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#DEFINE CRLF Chr(13)+Chr(10)
#DEFINE CR   Chr(13)
#DEFINE LF   Chr(10)

//---------------------------------------------------------------------------------------------------
/*/ {Protheus.doc} GFEXFILE
Classe leitura de arquivo texto usando FOpen(), pois na build abaixo o comando FT_FUSE() esta com problemas
TOTVS - Build 7.00.121227P - Jun 25 2013 - 10:52:35

Generico

@author André Luis Wisnheski
@since 21/08/13
@version 1.0
/*/
//-------------------------------------------------------------------------------------------------------

CLASS GFEXFile
	DATA cArquivo       // Caminho do arquivo de profile que está sendo manipulado.
	DATA cErro          // Mensagem de erro
	DATA aLinhas        // Todas as linhas do arquivo
	DATA nHandle        // Referencia do arquivo que está sendo manipulado.
	DATA nQtdeLin       // Quantidade de linhas do arquivo
	DATA nLinAtual      // Linha corrente
	DATA cCRLF          // Caracter que define o final de linha, dependendo do SO

	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD Clear()
	METHOD Open(cArquivo, bCtrlFluxo)
	METHOD Add(cBuffer)
	METHOD FEof()
	METHOD FNext()
	METHOD FPrior()
	METHOD Line()
	METHOD GetError()
ENDCLASS

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:New
Constructor da classe
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD New() CLASS GFEXFile
	self:cArquivo      := ""
	self:aLinhas       := {}
	self:nHandle       := -1
	self:nQtdeLin      := 0
	self:nLinAtual     := 0
	self:cCRLF         := CRLF
	self:cErro         := ""
RETURN

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:New
Limpar as variáveis da memória
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Clear() CLASS GFEXFile
	self:cArquivo      := ""
	self:aLinhas       := {}
	self:nHandle       := -1
	self:nQtdeLin      := 0
	self:nLinAtual     := 0
	self:cCRLF         := CRLF
	self:cErro         := ""
RETURN

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:Open
Abre o arquivo enviado e grava em array
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Open(cArquivo, bCtrlFluxo) Class GFEXFile
Local lRet        := .T.
Local cBuff       := ''
Local cLinha      := ''
Local nBuffSize   := 1048575
Local nLenghtFile := 0
Local nEol        := 0
Local nRead       := 0
Local nPos        := 0
Local nPosFile    := 0
Local nInc        := 0
Local cRetUTF8    := ""
	
	self:aLinhas  := {}
	self:cArquivo := cArquivo
	self:cErro    := ""

	If Empty(cArquivo)
		Self:cErro := "Arquivo vazio"
		lRet := .F.
	EndIf
	If lRet
		If self:nHandle >= 0
			FClose(self:nHandle)
			self:nHandle := -1
		EndIf

		/*Abrindo o arquivo*/
		self:nHandle := FOpen(self:cArquivo,FO_READ + FO_SHARED) // Parametros: Arquivo, Leitura - Escrita, Servidor
		If self:nHandle < 0
			Self:cErro := "Arquivo: '" + cArquivo + "' não é válido para importação."
			lRet := .F.
		EndIf
		If lRet
			nLenghtFile := FSeek(self:nHandle, 0, FS_END)
			FSeek(self:nHandle, 0, FS_SET)
			
			//Descobre a sequência de caracteres que define o final de linha
			//de acordo com o sistema operacional no qual o arquivo texto foi gerado
			nRead := FRead(self:nHandle,@cBuff,nBuffSize)
			If nRead > 0
				// Verifica se arquivo tem final de linha
				nPos := At(LF,SubStr(cBuff,1,nRead))
				Do Case
					Case nPos > 0
						cStrAux := SubStr(cBuff,1,nPos)
						If At(CR,cStrAux) > 0
							self:cCRLF := CRLF //Windows
							nInc := 1
						Else
							self:cCRLF := LF   //Linux
						EndIf
					Case At(CR  ,SubStr(cBuff,1,nRead)) > 0
						self:cCRLF := CR   //Mac
					Otherwise
						nInc := 1 //Para o correto posicionamento do ponteiro no arquivo
				End Case
			EndIf
		EndIf
	EndIf
	If lRet
		//Posiciona novamente no início do arquivo
		FSeek(self:nHandle, 0, FS_SET)
		Do While .T.
			// Bloco de código para barra de progresso ou outros controle de fluxo
			If bCtrlFluxo != Nil
				If ValType(bCtrlFluxo) == 'C'
					bCtrlFluxo := "{|nPosFile,nLenghtFile| "+ bCtrlFluxo +"}"
					bCtrlFluxo := &(bCtrlFluxo)
				EndIf 
				Eval(bCtrlFluxo,nPosFile,nLenghtFile)
			EndIf

			nPos     := FSeek(self:nHandle,0,FS_RELATIVE)
			nPosFile := nPos

			nRead := FRead(self:nHandle,@cBuff,nBuffSize)
			If nRead > 0
				cRetUTF8 := DecodeUTF8(cBuff)
				If cRetUTF8 != NIL
					cBuff := cRetUTF8
				EndIf
				cBuff := AnsiToOEM(cBuff)
				nEol := At(self:cCRLF,SubStr(cBuff,1,nRead))
				If nEol == 0 //Se não encontrar quebra de linha
					cLinha := FwNoAccent(SubStr(cBuff,1,Len(cBuff)))
				Else
					cLinha   := FwNoAccent(SubStr(cBuff,1,nEol-1))
					nPosFile := FSeek(self:nHandle,nPos+nEol+nInc,FS_SET)
				EndIf
			Else
				Exit
			EndIf

			If Len(AllTrim(cLinha)) > 3
				self:Add(cLinha)
			EndIf
		EndDo
		FClose(self:nHandle)
		self:nHandle   := -1
		self:nLinAtual := 1
	EndIf
Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:Add
Adiciona a linha em array
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Add(cBuffer) CLASS GFEXFile
	AAdd(self:aLinhas,cBuffer)
	self:nQtdeLin++
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:FEof
Verifica se chegou no final do arquivo
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD FEof() CLASS GFEXFile
Return (self:nQtdeLin <= 0)

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:FNext
Passa para a proxima linha do array
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD FNext() CLASS GFEXFile
	self:nLinAtual++
	self:nQtdeLin--
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:FPrior
Retorna para a linha anterior do array
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD FPrior() CLASS GFEXFile
	self:nLinAtual--
	self:nQtdeLin++
Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:Linha
Retorna para a linha corrente
Generico

@author André Luis W
@since 21/08/13
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD Line() CLASS GFEXFile
Return self:aLinhas[self:nLinAtual]
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEXFile:GetError()
Retorna o erro na abertura do arquivo
Generico

@author Squad GFE
@since 10/07/20
@version 1.0
/*///------------------------------------------------------------------------------------------------
METHOD GetError() CLASS GFEXFile
Return self:cErro
