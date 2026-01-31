#include "protheus.ch"

/*/{Protheus.doc} ArQrAFIP
Clase para generar QR en formato bmp con aplicacion en JAVA,
solo se genera la imagen, el codigo QR se controla con la clase ArQrAFIP
segun requerimientos de AFIP

@type Class
@version 
@author Francisco Guerrero
@since 21/5/2020
@return null
/*/
CLASS ArQrJava

    DATA cQrGen 
	DATA cPathQRgen
    DATA cPathJava
    DATA cPathTxtL
    DATA cPathTxtS
    DATA cPathTxtD
    DATA cPathBmpL
    DATA cPathBmpS
    DATA cPathBmpD
    DATA cString
    DATA cTxt 
    DATA cBmp
    DATA cClave

    	
	
	METHOD New() CONSTRUCTOR
    METHOD setTxt()
    METHOD setBmp()
    METHOD getString()
    METHOD getBmp()
	

	
ENDCLASS

/*/{Protheus.doc} New
Metodo constructor

@type metodo
@version 
@author Francisco Guerrero
@since 21/5/2020
@return null
/*/
METHOD New() CLASS ArQrJava
	
    Local cPathSrv   := GetSrvProfString("RootPath", "\undefined")
    Local cPathLocal := "C:\totvs\"

    ::cQrGen     := "qr-generator-1.0.1.jar"
	::cPathQRgen := cPathLocal+"totvs-qr-java"
    ::cPathJava  := ::cPathQRgen+"\"+"qr-generator-1.0.1"
    ::cPathTxtL  := ::cPathQRgen+"\"+"archivos_txt"
    ::cPathTxtS  := cPathSrv+"totvs-qr-java"+"\"+"archivos_txt"
    ::cPathBmpL  := ::cPathQRgen+"\"+"archivos_bmp"
    ::cPathBmpS  := cPathSrv+"totvs-qr-java"+"\"+"archivos_bmp"
    ::cString    := ""
    ::cClave     := ""
    ::cPathTxtD  := "\totvs-qr-java\archivos_txt"
    ::cPathBmpD  := "\totvs-qr-java\archivos_bmp"

    MakeDir(cPathLocal)
    MakeDir(::cPathTxtL)
    MakeDir(::cPathBmpL)

    MakeDir("\totvs-qr-java")
    MakeDir(::cPathTxtD)
    MakeDir(::cPathBmpD)

RETURN SELF
/*/{Protheus.doc} setString
    Setea datos del txt para generar el QR, debe informars el string y la clave del comprobante
    que sera utilizada para separar los archivos en las carpetas internas

    @type  Function
    @author user
    @since 06/01/2021
    @version version
    @param cClaveQr, String, Datos del comprobante identificatorio
    @param cStringQr, String, string a generar con BMP de QR
    @return nil
    @example
    setTxt("0101-NFA-000100000002","http://nnnn.com")
    @see (links_or_references)
/*/
METHOD setTxt(cClaveQr,cStringQr) CLASS ArQrJava
    
    Local lRet   := .T.
    Local cTxtL:= ::cPathTxtL+"\"+cClaveQr+".txt"
    Local cTexto := cStringQr+CRLF
    cTexto += ::cPathBmpL+"\"+cClaveQr
    
    ::cClave  := cClaveQr
    ::cString := cStringQr
    ::cTxt    := ::cPathTxtD+"\"+cClaveQr+".txt"
    ::cBmp    := ::cPathBmpD+"\"+cClaveQr+".bmp"

   lRet := MemoWrite(cTxtL , cTexto)//generar txt localmente
   lRet := CpyT2S(cTxtL,::cPathTxtD)//copia a server


Return lRet
/*/{Protheus.doc} setString
   ejecutamos JAVA local en maquina de usuario  para generar QR en formato BMP
   Luego se copia el archivo BMP al servidor de Protheus

    @type  Function
    @author user
    @since 06/01/2021
    @version version
    @param nil
    @return nil
    @example
    setBmp()
    @see (links_or_references)
/*/
METHOD setBmp() CLASS ArQrJava
   
   Local lRet:= .T.
   Local cDirBat := ::cPathJava
   Local cBat := ::cPathQRgen+"\qrgenerator.BAT "+::cClave+".txt "
   Local cBmpL:= ::cPathBmpL+"\"+cClaveQr+".bmp"
   
   lRet := WaitRun(cBat, 0)
   lRet := CpyT2S(cBmpL,::cPathBmpD)//copia a server

Return lRet

