#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

Static cMvSerie 	:= STFGetStat("LG_SERIE") //Serie da nota	

//-------------------------------------------------------------------
/*/{Protheus.doc} STBNumSx5
Funcao que gera o numero a partir das tabelas: Sx5 ou Sxe/Sxf
A escolha das tabelas a serem utilizadas na numeracao e configurada a partir
do parametro MV_LJNRNFS.

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cNumber - Retorno da numeracao pela Sx5 ou Sxe/Sxf
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBNumSx5()

Local cNumber	:= "" //Armazena o numero da nota
	
cNumber := NxtSX5Nota( cMvSerie,, SuperGetMV("MV_LJNRNFS",.F.,"2"))

Return cNumber


//-------------------------------------------------------------------
/*/{Protheus.doc} STBNumSd9
A partir da rotina MA461NumNf gera o numero da tabela Sd9

@param   	Nil
@author  	Varejo
@version 	P11.8
@since   	30/03/2012
@return  	cNumber - Retorno da numeracao pela Sd9
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBNumSd9()

Local cNumber	 := "" 						//Armazena o numero da nota
Local nTamDoc	 := TamSx3("L1_DOC")[1]	//Tamanho do campo L1_DOC na Sx3

cNumber := PadR( MA461NumNf( .T., cMvSerie ) , nTamDoc )
	
Return cNumber