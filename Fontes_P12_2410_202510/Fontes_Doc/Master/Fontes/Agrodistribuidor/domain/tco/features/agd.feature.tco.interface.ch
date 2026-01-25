#include "tlpp-core.th"


Interface FeatureTCO
    Public Method getCodigo() as character
    Public Method getDescricao() as character
    Public Method getTipo() as character
    Public Method getParametros() as array
    Public Method getCadastrosBasicos() as array
    Public Method getRelease() as character
    Public Method getCompartilhamentoTabela() as array
EndInterface
