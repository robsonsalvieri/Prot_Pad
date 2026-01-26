#include "tlpp-core.th"

Interface WMSSaasConvergenciaInterface
   Public Method loadByChave(cDoc as character, cSerie as character, cCliFor as character, cLoja as character) as object
   Public Method canBeUpdated() as logical
   Public Method finaliza(cMessage as character) as logical
   Public Method getNomePessoa() as character
EndInterface

Interface WMSSaasConvergenciaAdapterInterface
   Public Method getAll(nPage as integer, nPageSize as integer) as json
   Public Method getById(cId as character,nPage as integer, nPageSize as integer) as json
   Public Method finaliza(cMessage as character, oJson as json) as logical
EndInterface
