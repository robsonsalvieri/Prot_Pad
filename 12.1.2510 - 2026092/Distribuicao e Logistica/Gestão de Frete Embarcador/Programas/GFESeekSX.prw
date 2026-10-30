#INCLUDE 'PROTHEUS.CH'

Function GFESeekSX()
Return Nil
//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc}GFESeekSX()

@author Andre Wisnheski
@since 11/5/2018
@version 1.0
/*/
//---------------------------------------------------------------------------------------------------
CLASS GFESeekSX FROM LongNameClass 

   DATA cCampo
   DATA cX3Titulo
   DATA nX3Tamanho
   DATA nX3Decimal
   DATA cX3Picture

   METHOD New() CONSTRUCTOR
   METHOD ClearData()
   METHOD Destroy(oObject)
   METHOD SeekX3(cCampo, lFindTit, lFindPic, lFindTam)

   METHOD setCampo(cCampo)
   METHOD setX3Titulo(cX3Titulo)
   METHOD setX3Tamanho(nX3Tamanho)
   METHOD setX3Decimal(nX3Decimal)
   METHOD setX3Picture(cX3Picture)

   METHOD getCampo()
   METHOD getX3Titulo()
   METHOD getX3Tamanho()
   METHOD getX3Decimal()
   METHOD getX3Picture()

ENDCLASS

METHOD New() Class GFESeekSX
   Self:ClearData()
Return

METHOD Destroy(oObject) CLASS GFESeekSX
   FreeObj(oObject)
Return

METHOD ClearData() Class GFESeekSX
	Self:cCampo		:= ''
	Self:cX3Titulo	:= ''
	Self:nX3Tamanho	:= 0
	Self:nX3Decimal	:= 0
	Self:cX3Picture	:= ''
Return

METHOD SeekX3(cCampo, lFindTit, lFindPic, lFindTam)  Class GFESeekSX
	Local aTamSX3 := {}
	
	Default lFindTit := .T.
	Default lFindPic := .T.
	Default lFindTam := .T.
	
	Self:setCampo(cCampo)
	
	IIF(lFindTit,Self:setX3Titulo(FWX3Titulo(Self:getCampo())),"")
	IIF(lFindPic,Self:setX3Picture(X3Picture(Self:getCampo())),"")
	IF lFindTam
		aTamSX3 := TamSX3(Self:getCampo())
		Self:setX3Tamanho(aTamSX3[1])
		Self:setX3Decimal(aTamSX3[2])
	EndIf
Return

//-----------------------------------
//Setters
//-----------------------------------
METHOD setCampo(cCampo) CLASS GFESeekSX
   Self:cCampo := cCampo
Return

METHOD setX3Titulo(cX3Titulo) CLASS GFESeekSX
   Self:cX3Titulo := cX3Titulo
Return

METHOD setX3Tamanho(nX3Tamanho) CLASS GFESeekSX
   Self:nX3Tamanho := nX3Tamanho
Return

METHOD setX3Decimal(nX3Decimal) CLASS GFESeekSX
   Self:nX3Decimal := nX3Decimal
Return

METHOD setX3Picture(cX3Picture) CLASS GFESeekSX
   Self:cX3Picture := cX3Picture
Return


//-----------------------------------
//Getters
//-----------------------------------
METHOD getCampo() CLASS GFESeekSX
Return Self:cCampo

METHOD getX3Titulo() CLASS GFESeekSX
Return Self:cX3Titulo

METHOD getX3Tamanho() CLASS GFESeekSX
Return Self:nX3Tamanho

METHOD getX3Decimal() CLASS GFESeekSX
Return Self:nX3Decimal

METHOD getX3Picture() CLASS GFESeekSX
Return Self:cX3Picture