#include "TOTVS.CH"

/*/{Protheus.doc}
    Classe concreta da Entidade CenB2W - Synthetic Dmed Reimburse
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB2W from CenEntity

    Method New()

    Method destroy()
    Method getIdeOri()
    Method getDesOri()

EndClass

Method New() Class CenB2W
    _Super:New()
Return self

Method destroy() Class CenB2W
    _Super:destroy()
    DelClassIntF()
return

Method getIdeOri() Class CenB2W
Return B2W->(B2W_FILIAL+B2W_CODOPE+B2W_CODOBR+B2W_ANOCMP+B2W_CDCOMP+B2W_CPFTIT+B2W_CPFBEN+DTOS(B2W_DTNASD)+B2W_NOMBEN+B2W_CPFPRE+B2W_IDEREG)

Method getDesOri() Class CenB2W
Return B2W->B2W_NOMBEN