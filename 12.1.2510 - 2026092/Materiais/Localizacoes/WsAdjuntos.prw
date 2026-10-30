#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://demoemision21v4.thefactoryhka.com.co/ws/adjuntos/Service.svc?wsdl
Generado en        06/11/25 13:28:32
Observaciones      Codigo Fuente generado por ADVPL WSDL Client 1.120703
                 Modificaciones en este archivo pueden causar funcionamiento incorrecto
                 y se perderan en caso de que se genere nuevamente el codigo fuente.
=============================================================================== */

User Function _JPQYSRR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSAdjuntos
------------------------------------------------------------------------------- */

WSCLIENT WSAdjuntos

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CargarAdjuntos

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ctokenEmpresa             AS string
	WSDATA   ctokenPassword            AS string
	WSDATA   oadjunto                AS ServiceAdjuntos_CargarAdjuntos
	WSDATA   oWSCargarAdjuntosResult   AS Service_UploadAttachmentResponse
	WSDATA   cnumeroDocumento          AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAdjuntos
::Init()
Return Self

WSMETHOD INIT WSCLIENT WSAdjuntos
	::oadjunto         := ServiceAdjuntos_CargarAdjuntos():New()
	::oWSCargarAdjuntosResult := Service_UPLOADATTACHMENTRESPONSE():New()
Return

// WSDL Method CargarAdjuntos of Service WSAdjuntos

WSMETHOD CargarAdjuntos WSSEND ctokenEmpresa,ctokenPassword,oadjunto WSRECEIVE oWSCargarAdjuntosResult WSCLIENT WSAdjuntos
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CargarAdjuntos xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("tokenEmpresa", ::ctokenEmpresa, ctokenEmpresa , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("tokenPassword", ::ctokenPassword, ctokenPassword , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("adjunto", ::oadjunto, oadjunto , "CargarAdjuntos", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CargarAdjuntos>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://tempuri.org/IService/CargarAdjuntos",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://demoemision21v4.thefactoryhka.com.co/ws/adjuntos/Service.svc")

::Init()
::oWSCargarAdjuntosResult:SoapRecv( WSAdvValue( oXmlRet,"_CARGARADJUNTOSRESPONSE:_CARGARADJUNTOSRESULT","UploadAttachmentResponse",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Data Structure CargarAdjuntos

WSSTRUCT ServiceAdjuntos_CargarAdjuntos
	WSDATA archivo           AS string OPTIONAL
    WSDATA email             AS ServiceAdjuntos_ArrayOfstring OPTIONAL
    WSDATA enviar            AS string OPTIONAL
    WSDATA formato           AS string OPTIONAL
    WSDATA nombre            AS string OPTIONAL
    WSDATA numeroDocumento   AS string OPTIONAL
    WSDATA tipo              AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ServiceAdjuntos_CargarAdjuntos
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ServiceAdjuntos_CargarAdjuntos
Return

WSMETHOD SOAPSEND WSCLIENT ServiceAdjuntos_CargarAdjuntos
	Local cSoap := ""
	cSoap += WSSoapValue("archivo", ::archivo, ::archivo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("email", ::email, ::email , "ArrayOfstring", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)
	cSoap += WSSoapValue("enviar", ::enviar, ::enviar , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("formato", ::formato, ::formato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("nombre", ::nombre, ::nombre , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("numeroDocumento", ::numeroDocumento, ::numeroDocumento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.) 
	cSoap += WSSoapValue("tipo", ::tipo, ::tipo , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/ServiceSoap.UBL2._0.Models.Object", .F.,.F.)

Return cSoap

// WSDL Data Structure UploadAttachmentResponse

WSSTRUCT Service_UploadAttachmentResponse
    WSDATA codigo               AS numeric OPTIONAL
    WSDATA mensaje              AS string OPTIONAL
    WSDATA mensajesValidacion   AS ServiceAdjuntos_ArrayOfstring OPTIONAL
    WSDATA resultado            AS string OPTIONAL

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Service_UploadAttachmentResponse
    ::Init()
Return Self

WSMETHOD INIT WSCLIENT Service_UploadAttachmentResponse
Return Self

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Service_UploadAttachmentResponse
	If oResponse = NIL ; Return ; EndIf
	::codigo := WSAdvValue( oResponse,"_a_codigo","string",NIL,NIL,NIL,NIL,NIL,NIL)
	::mensaje := WSAdvValue( oResponse,"_a_mensaje","string",NIL,NIL,NIL,NIL,NIL,NIL)
	::mensajesValidacion := WSAdvValue( oResponse,"_a_mensajesvalidacion","string",NIL,NIL,NIL,NIL,NIL,NIL)
	::resultado := WSAdvValue( oResponse,"_a_resultado","string",NIL,NIL,NIL,NIL,NIL,NIL)
Return

// WSDL Data Structure ArrayOfstring

WSSTRUCT ServiceAdjuntos_ArrayOfstring
	WSDATA   cstring                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ServiceAdjuntos_ArrayOfstring
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ServiceAdjuntos_ArrayOfstring
	::cstring              := {}
Return

WSMETHOD SOAPSEND WSCLIENT ServiceAdjuntos_ArrayOfstring
	Local cSoap := ""
	aEval( ::cstring , {|x| cSoap := cSoap  +  WSSoapValue("string", x , x , "string", .F. , .F., 0 , "http://schemas.microsoft.com/2003/10/Serialization/Arrays", .F.,.F.)  } ) 
Return cSoap
