#include "tlpp-core.th"


Interface FeatureTCO
    Public Method getCodigo() as character
    Public Method getDescricao() as character
    Public Method getTipo() as character
    Public Method getParametros() as array
    Public Method getCadastrosBasicos() as array
    Public Method getRelease() as character
    Public Method getIdentificaoIntegracao() as character
    Public Method getTabelasDePara() as array 
    Public Method getDocumentacaoTDN() as character
    Public Method getAdapter() as array
    Public Method getCheckAtivacao() as array
    Public Method getCheckFinalizacao() as array
EndInterface
