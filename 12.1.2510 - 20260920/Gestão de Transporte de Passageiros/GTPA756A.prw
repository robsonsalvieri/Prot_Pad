#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static Function ViewDef()

    Local oView     := FwLoadView("GTPA756")
    Local oStrH6K   := oView:GetViewStruct("VIEW_H6K")

    ViewStruct(@oStrH6K)
    
Return(oView)

Static Function ViewStruct(oStrH6K)
    
    oStrH6K:RemoveField("H6K_DOC")
    oStrH6K:RemoveField("H6K_SERIE")
    oStrH6K:RemoveField("H6K_FOREMP")
    oStrH6K:RemoveField("H6K_LJFOEM")
    oStrH6K:RemoveField("H6KDEMPFOR")
    oStrH6K:RemoveField("H6K_DOCONS")
    oStrH6K:RemoveField("H6K_FORPAS")
    oStrH6K:RemoveField("H6K_LJFOPA")
    oStrH6K:RemoveField("H6KDPASFOR")
    oStrH6K:RemoveField("H6K_STATUS")
    oStrH6K:RemoveField("H6K_DTENVI")
    oStrH6K:RemoveField("H6K_HRENVI")
    oStrH6K:RemoveField("H6K_USRENV")
    oStrH6K:RemoveField("H6KUSENVNM")
    oStrH6K:RemoveField("H6K_DTRECE")
    oStrH6K:RemoveField("H6K_HRRECE")
    oStrH6K:RemoveField("H6K_USRECE")
    oStrH6K:RemoveField("H6KUSRECNM")
    oStrH6K:RemoveField("H6K_DTRETI")
    oStrH6K:RemoveField("H6K_HRRETI")
    oStrH6K:RemoveField("H6K_USRETI")
    oStrH6K:RemoveField("H6KUSRETNM")
    oStrH6K:RemoveField("H6K_DTREEM")
    oStrH6K:RemoveField("H6K_HRREEM")
    oStrH6K:RemoveField("H6K_USREEM")
    oStrH6K:RemoveField("H6KUSREENM")
    oStrH6K:RemoveField("H6K_PREFIX")
    oStrH6K:RemoveField("H6K_NUM")
    oStrH6K:RemoveField("H6K_PARCEL")
    oStrH6K:RemoveField("H6K_TIPO")

Return()
