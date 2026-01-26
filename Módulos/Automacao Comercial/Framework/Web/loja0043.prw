#INCLUDE "PROTHEUS.CH"

// O protheus necessita ter ao menos uma fun็ใo p๚blica para que o fonte seja exibido na inspe็ใo de fontes do RPO.
Function LOJA0043() ; Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     Classe: ณ LJCFileDownloaderDownloadProgress ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Representativo do progresso da baixa do arquivo.                       บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LJCFileDownloaderDownloadProgress From FWSerialize
	Data cFileName
	Data nTotalBytes
	Data nDownloadedBytes
	Data nBytesPerSecond
	Data nBufferSize
	Data nSecondsLeft
	Data nStatus
	
	Method New()
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออัอออออออออออออออออออออออออออออออออออัอออออออออออออออออออัออออออออออออออออปฑฑ
ฑฑบ     M้todo: ณ New                               ณ Autor: Vendas CRM ณ Data: 07/02/10 บฑฑ
ฑฑฬอออออออออออออุอออออออออออออออออออออออออออออออออออฯอออออออออออออออออออฯออออออออออออออออนฑฑ
ฑฑบ  Descri็ใo: ณ Contrutor                                                              บฑฑ
ฑฑบ             ณ                                                                        บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros: ณ cFileName: Nome do arquivo.                                            บฑฑ
ฑฑบ             ณ nTotalBytes: Tamanho total do arquivo em bytes.                        บฑฑ
ฑฑบ             ณ nDownloadedBytes: Bytes jแ baixados do arquivo.                        บฑฑ
ฑฑบ             ณ nBytesPerSecond: Taxa de transfer๊ncia de bytes por segundo.           บฑฑ
ฑฑบ             ณ nBufferSize: Tamanho do pacote de cada parte baixada.                  บฑฑ
ฑฑบ             ณ nSecondsLeft: Segundos que falta para baixar completamente o arquivo.  บฑฑ
ฑฑบ             ณ nStatus: Status do download do arquivo, sendo:                         บฑฑ
ฑฑบ             ณ          1 - Iniciado.                                                 บฑฑ
ฑฑบ             ณ          2 - Baixando.                                                 บฑฑ
ฑฑบ             ณ          3 - Finalizado.                                               บฑฑ
ฑฑบ             ณ          4 - Erro.                                                     บฑฑ
ฑฑฬอออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ    Retorno: ณ                                                                        บฑฑ
ฑฑศอออออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method New( cFileName, nTotalBytes, nDownloadedBytes, nBytesPerSecond, nBufferSize, nSecondsLeft, nStatus ) Class LJCFileDownloaderDownloadProgress
	Default cFileName		:= ""
	Default nTotalBytes		:= 0
	Default nDownloadedBytes:= 0
	Default nBytesPerSecond	:= 0
	Default nBufferSize		:= 0
	Default nSecondsLeft	:= 0
	Default nStatus			:= 0

	Self:cFileName			:= cFileName
	Self:nTotalBytes		:= nTotalBytes
	Self:nDownloadedBytes	:= nDownloadedBytes
	Self:nBytesPerSecond	:= nBytesPerSecond
	Self:nBufferSize		:= nBufferSize
	Self:nSecondsLeft		:= nSecondsLeft
	Self:nStatus			:= nStatus
Return
