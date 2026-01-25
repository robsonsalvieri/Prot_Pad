// ######################################################################################
// Projeto: DATA WAREHOUSE
// Modulo : Ferramentas
// Fonte  : FileIO - Definie objeto tDWFileIo, usado para efetuar operações de I/O
// ---------+-------------------+--------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+--------------------------------------------------------
// 01.06.01 | 0548-Alan Candido |
// 14.11.07 | 0548-Alan Candido | BOPS 135941 - Implementação do método filePos()
// 25.11.08 | 0548-Alan Candido | FNC 00000007374/2008 (10) e 00000007385/2008 (8.11)
//          |                   | Implementação dos métodos fileAge() e lastUpd()
// --------------------------------------------------------------------------------------

#include "dwincs.ch"

/*
--------------------------------------------------------------------------------------
Classe: TDWFileIO
Uso   : Efetua o I/O em arquivos
--------------------------------------------------------------------------------------
*/
class TDWFileIO from TDWObject
	data fnHandle
	data fcFilename
	data fcFileCtrl                
	data flCripto
	data flBinaryFile
	data fnOutRootPath
	
	method New(acFilename, alCripto) constructor
	method Free()

	method Create(anMode)
	method Open(anMode)
	method Append(anMode)
	method Close()
	method IsOpen()
	method GetError()
	method Exists()
	method Size()
	method Erase()
	method WriteLN(acBuffer)
	method Write(acBuffer, anBytes)
	method Seek(anOffSet, anOrigin)
	method Read(acBuffer, anBytes )
	method Readln(acBuffer)
	method GoBOF() 
	method GoEOF() 
	method Go(anOffset) 
	method StartCtrl()
	method StopCtrl()
	method CtrlExist()
	method ChgFileExt(acFilename, acExtension)
	method Rename(acNewFilename)
  method filePos()
	
	method Handle()       	 // Handle associado ao arquivo
	method Filename(acValue) // Nome do arquivo
	method BinaryFile(alValue)
  method fileAge()
  method lastUpd()

endclass

/*
--------------------------------------------------------------------------------------
Construtor e destrutor da classe
--------------------------------------------------------------------------------------
*/
method New(acFilename, alCripto) class TDWFileIO
	default alCripto := .f.
	
	_Super:New()

	::fnHandle := NIL
	::fcFilename := fileFisicalDirectory(acFilename)
	::fcFileCtrl := ""                
	::flCripto := alCripto
	::flBinaryFile := .f.
	::fnOutRootPath := iif((":" $ acFilename .and. ::fcFilename == acFilename) .or. ;
                         ("\\" $ acFilename .and. ::fcFilename == acFilename), 1, 0)
return

method Free() class TDWFileIO
	
	if ::isOpen()
		::Close()
	endif

	_Super:Free()
	
return     

/*
--------------------------------------------------------------------------------------
Retorna o código de erro da última operação de I/O
Arg: 
Ret: nRet -> numerico, código de erro
--------------------------------------------------------------------------------------
*/
method GetError() class TDWFileIO

return (FError())

/*
--------------------------------------------------------------------------------------
Determina se o arquivo encontra-se aberto
Arg: 
Ret: lRet -> logico, indica se esta aberto
--------------------------------------------------------------------------------------
*/
method IsOpen() class TDWFileIO

return (::Handle() <> NIL)

/*
--------------------------------------------------------------------------------------
Cria o arquivo em disco
Arg: anMode -> numerico, modo de criação de arquivo
Ret: lRet -> logico, indica que a abertura foi OK
--------------------------------------------------------------------------------------
*/
method Create(anMode) class TDWFileIO
	
	if ::isOpen()
		::Close()
	endif
	
	default anMode := FC_NORMAL

	::fnHandle := FCreate(::Filename(), anMode, ::fnOutRootPath)
	if ::GetError() <> 0 
		::fnHandle := NIL		
	end
	
return (::isOpen())

/*
--------------------------------------------------------------------------------------
Abre o arquivo no disco
Arg: anMode -> numerico, modo de criação de arquivo
Ret: lRet -> logico, indica que a abertura foi OK
--------------------------------------------------------------------------------------
*/
method Open(anMode)  class TDWFileIO

	default anMode := FO_READ
	
	if ::isOpen()
		::Close()
	endif
	
	::fnHandle := FOpen(::Filename(), anMode, ::fnOutRootPath)
	if ::GetError() <> 0 
		::fnHandle := NIL
	end

return (::isOpen())

/*
--------------------------------------------------------------------------------------
Abre o arquivo no disco em modo "append"
Arg: anMode -> numerico, modo de criação de arquivo
Ret: lRet -> logico, indica que a abertura foi OK
--------------------------------------------------------------------------------------
*/
method Append(anMode)  class TDWFileIO
	
	default anMode := FO_READWRITE notdef (anMode + FO_READWRITE)

	::Open(anMode)
		
	if ::isOpen()
		::GoEOF()
	endif
return (::isOpen())

/*
--------------------------------------------------------------------------------------
Fecha o arquivo 
Arg: 
Ret: lRet -> logico, indica que o fechamento foi OK
--------------------------------------------------------------------------------------
*/
method Close() class TDWFileIO
	
	if ::isOpen()
		FClose(::Handle())
		::fnHandle := NIL
	end

return (::GetError() <> 0)

/*
--------------------------------------------------------------------------------------
Le um buffer         
Arg: @acBuffer -> string, buffer a ser lido
     anBytes -> numerico, tamanho do buffer a ler
Ret: nRet -> numero de bytes lidos
--------------------------------------------------------------------------------------
*/
method Read(acBuffer, anBytes) class TDWFileIO
	local nRet := -1   
	
	default acBuffer = space(SIZE_BUFFER)
	default anBytes = len(acBuffer) 
	
	If ::isOpen()
		if ::BinaryFile()
			acBuffer := FReadStr(::Handle(), anBytes)
			nRet := anBytes
		else
			nRet := FRead(::Handle(), @acBuffer, anBytes)
			acBuffer := substr(acBuffer, 1, nRet)
	  	endif
		if ::flCripto 
			acBuffer := DWUncripto(acBuffer)
  		endif
	end             
	
return nRet

method Readln(acBuffer) class TDWFileIO
	local nRet := -1, nPos
	local cBuffer := space(SIZE_BUFFER)
	
	if ::isOpen()
   	acBuffer := ''
		if ::BinaryFile() .or. ::flCripto 
			DWRaise(ERR_002, SOL_005, " ")
		else                                  
		   while (nRet := FRead(::Handle(), @cBuffer, SIZE_BUFFER)) > 0
           if (nPos := at(CRLF, cBuffer)) > 0
           	acBuffer += left(cBuffer, nPos -1)
           	::seek(-(len(cBuffer) - (nPos + 1)), FS_RELATIVE)
           	exit
           else 
           	acBuffer += cBuffer
           endif
		   enddo 
			nRet := len(acBuffer)
	  	endif
	end             
	
return nRet
/*
--------------------------------------------------------------------------------------
Grava um buffer         
Arg: acBuffer -> string, buffer a ser gravado
     anBytes -> numerico, tamanho do buffer
Ret: nRet -> numero de bytes gravados
--------------------------------------------------------------------------------------
*/
method WriteLN(acBuffer) class TDWFileIO

return ::Write(acBuffer,, CRLF) 

method Write(acBuffer, anBytes, acTerminal) class TDWFileIO
	local nRet := -1, cBuffer
	
	if ::isOpen()
		default acBuffer := ''
		default acTerminal := ''
		cBuffer := acBuffer + acTerminal
		default anBytes := len(cBuffer)
		if ::flCripto 
			nRet := fWrite(::Handle(), DWCripto(acBuffer, anBytes*2)+acTerminal, (anBytes*2)+len(acTerminal))
		else
			nRet := fWrite(::Handle(), acBuffer+acTerminal, anBytes+len(acTerminal))
		endif
	end

return nRet

/*
--------------------------------------------------------------------------------------
Posiciona o ponteiro no inicio do arquivo
Arg: 
Ret: nRet -> numero de bytes deslocados
--------------------------------------------------------------------------------------
*/
method GoBOF() class TDWFileIO

return ::Seek(0, FS_SET) 

/*
--------------------------------------------------------------------------------------
Posiciona o ponteiro ao final do arquivo
Arg: 
Ret: nRet -> numero de bytes deslocados
--------------------------------------------------------------------------------------
*/
method GoEOF() class TDWFileIO

return ::Seek(0, FS_END) 

/*
--------------------------------------------------------------------------------------
Posiciona o ponteiro 
Arg: anOffset -> numerico, valor do deslocamento
Ret: nRet -> numero de bytes deslocados
--------------------------------------------------------------------------------------
*/
method Go(anOffset) class TDWFileIO

return ::Seek(anOffset, FS_SET) 

/*
--------------------------------------------------------------------------------------
Retorna o tamanho do arquivo
Ret: nRet -> numero de bytes
--------------------------------------------------------------------------------------
*/
method Size() class TDWFileIO
	local nRet := -1
	
	if ::isOpen()
		nRet := FSeek(::Handle(), 0, FS_END)
		FSeek(::Handle(), 0)
	endif
	
return nRet  

/*
--------------------------------------------------------------------------------------
Retorna a posição atual
Ret: nRet -> numero de bytes
--------------------------------------------------------------------------------------
*/
method filePos() class TDWFileIO
	
return FSeek(::Handle(), 0, FS_RELATIVE)

/*
--------------------------------------------------------------------------------------
Posiciona o ponteiro
Arg: anOffset -> numerico, valor do deslocamento
     anOrigin -> numerico, ponto de origem do deslocamento
Ret: nRet -> numero de bytes deslocados
--------------------------------------------------------------------------------------
*/
method Seek(anOffSet, anOrigin) class TDWFileIO
	local nRet := -1
	
	if ::isOpen()
	   nRet := FSeek(::Handle(), anOffSet, anOrigin)
	endif
	
return nRet  

/*
--------------------------------------------------------------------------------------
Verifica a existencia do arquivo
Arg: 
Ret: lRet -> logico, retorna se existe
--------------------------------------------------------------------------------------
*/
method Exists() class TDWFileIO

return (file(::Filename()))

/*
--------------------------------------------------------------------------------------
Remove o arquivo do disco
Arg: 
Ret: lRet -> logico, retorna se remoção foi OK
--------------------------------------------------------------------------------------
*/
method Erase() class TDWFileIO

	ferase(::Filename(), ::fnOutRootPath)

return (::GetError() == 0)

/*
--------------------------------------------------------------------------------------
Retorna o handle do arquivo
--------------------------------------------------------------------------------------
*/
method Handle() class TDWFileIO

return (::fnHandle)

/*
--------------------------------------------------------------------------------------
Retorna o nome do arquivo
--------------------------------------------------------------------------------------
*/
method Filename(acValue) class TDWFileIO

	property ::fcFilename := acValue
	
return (::fcFilename)

/*
--------------------------------------------------------------------------------------
Indica se o arquivo é binário ou não
--------------------------------------------------------------------------------------
*/
method BinaryFile(alValue) class TDWFileIO

	property ::flBinaryFile := alValue
	
return (::flBinaryFile)

/*
--------------------------------------------------------------------------------------
Cria o arquivo de controle
--------------------------------------------------------------------------------------
*/
method StartCtrl() class TDWFileIO            
	local nHandle 
   
  ::fcFileCtrl := ::ChgFileExt(::Filename(), '.ctl')
	nHandle := FCreate(::fcFileCtrl, FC_NORMAL)
	FClose(nHandle)
	
return

/*
--------------------------------------------------------------------------------------
Remove o arquivo de controle
--------------------------------------------------------------------------------------
*/
method StopCtrl() class TDWFileIO            
       
	FErase(::fcFileCtrl)
	::fcFileCtrl := ""
	
return 

/*
--------------------------------------------------------------------------------------
Verifica se existe ou não o arquivo de controle
Arg:
Ret: lRet -> lógico, indica a existencia ou não do arquivo de controle
--------------------------------------------------------------------------------------
*/
method CtrlExist() class TDWFileIO

return (file(::fcFileCtrl))

/*
--------------------------------------------------------------------------------------
Troca a extensão do nome de arquivo
Arg: acFilename -> string, nome do arquivo
     acExtension -> string, nova extensão
Ret: cRet -> string, nome do arquivo com a nova extensão
--------------------------------------------------------------------------------------
*/
method ChgFileExt(acFilename, acExtension) class TDWFileIO
	
return DWChgFileExt(acFilename, acExtension)

/*
--------------------------------------------------------------------------------------
Renomeia o arquivo
--------------------------------------------------------------------------------------
*/
method Rename(acNewFilename) class TDWFileIO
	local lOk 
	
	frename(::fcFilename, acNewFilename)
	lOk := !file(::fcFilename)
	if lOk
		::Filename(acNewFilename) 
	endif

return lOk

/*
--------------------------------------------------------------------------------------
Retorna a idade do arquivo
Ret: nRet -> idade em dias
--------------------------------------------------------------------------------------
*/
method fileAge() class TDWFileIO
	local aFiles := directory(::filename())
  local nRet := -1

	if len(aFiles) > 0
		nRet := date() - aFiles[1,3]
	endif
	
return nRet

/*
--------------------------------------------------------------------------------------
Retorna a data da ultima atualização
Ret: date -> data da ultima modificação
--------------------------------------------------------------------------------------
*/
method lastUpd() class TDWFileIO
	local aFiles := directory(::filename())
  local dRet := ctod("  /  /  ")

	if len(aFiles) > 0
		dRet := aFiles[1,3]
	endif
		
return dRet
