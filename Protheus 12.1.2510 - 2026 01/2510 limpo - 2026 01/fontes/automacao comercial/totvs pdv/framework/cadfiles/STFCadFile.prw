#Include 'Protheus.ch'

//--------------------------------------------------------
/*/{Protheus.doc} STFCadFile
     

@param   	                                        
@author  	Varejo
@version 	P11.8
@since   	24/07/2013
@return  	 
@obs     	Nil
@sample   	Nil
/*/
//--------------------------------------------------------
Function STFCadFile()
Return

//--------------------------------------------------------
/*/{Protheus.doc} STFRetDlls
Retorna os arquivos utilizados pelo sistema     

@param   	                                        
@author  	Varejo
@version 	P11.8
@since   	24/07/2013
@return  	aRet - Retorna um array com os arquivos que foram cadastrados 
@obs     	Nil
@sample   	Nil
/*/
//--------------------------------------------------------
Function STFGetFiles()

Local aRet := {}

Aadd(aRet, {'Totvs','SigaLoja.dll','0.3.135.13'})
Aadd(aRet, {'Totvs','TotvsApi.dll','1.0.14.2'})
Aadd(aRet, {'Totvs','AutoCom.dll','3.4.1.3'})
Aadd(aRet, {'Bematech','BemaFI32.dll',''})
Aadd(aRet, {'Bematech','BemaFI32.ini',''})

Return aRet