#Include "Protheus.ch"
#Include "RwMake.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} CENIMPXTR
Descricao: Importacao de arquivo XTR de Retorno da ANS. 

@author Hermiro Júnior
@since 30/08/2019
@version 1.0

@Param:

/*/
//-------------------------------------------------------------------
Function CENIMPXTR(lAutom)

  Default lAutom := .F.

  EnvArqSer("*.xtr|*.xtr","Importar arquivos de Retorno .XTR","1",lAutom)
  
Return
