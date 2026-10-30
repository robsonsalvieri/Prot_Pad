#Include 'Protheus.ch'

Static aFREListFunc	:= {}


/*/{Protheus.doc} GTPHasAccess
Verifica se há acesso ao módulo 88 GTP ou 72 FRE
@type function
@author Fernando Radu Muscalu
@since 13/03/2023
@version 1.0
@return lRet, .t. tem acesso, .f. não tem acesso
@example
(examples)
@see (links_or_references)
/*/
Function GTPHasAccess()
	
	Local lRet := .T.
	
	FRELoadFunctionList()

	lRet := IIf( !AmIin(88),; 
				AmIin(72) .And. aScan(aFREListFunc,{|x| Upper(Alltrim(FunName()))}) > 0,;
			.t.)
   
Return(lRet)

/*/{Protheus.doc} FRELoadFunctionList
Carrega array com todas as funções do módulo FRE
@type function
@author Fernando Radu Muscalu
@since 13/03/2023
@version 1.0
@return aFREListFunc, array, Array Estático com a lista 
	de funções do módulo FRE
@example
(examples)
@see (links_or_references)
/*/
Function FRELoadFunctionList(lMount)

    Local lRemake   := .f.

    Default lMount  := .f.

    lRemake := lMount

    lRemake := Iif(!lRemake, (Len(aFREListFunc) == 0 .Or. Len(aFREListFunc) <> 73) ,.f.)

    If ( lRemake )

		aAdd(aFREListFunc,"GTPA011")
		aAdd(aFREListFunc,"GTPA000")
		aAdd(aFREListFunc,"GTPA010")
		aAdd(aFREListFunc,"GTPA035")
		aAdd(aFREListFunc,"GTPA022")
		aAdd(aFREListFunc,"GTPA317")
		aAdd(aFREListFunc,"GTPA001")
		aAdd(aFREListFunc,"GTPA008")
		aAdd(aFREListFunc,"GTPA005")
		aAdd(aFREListFunc,"GTPA002")
		aAdd(aFREListFunc,"GTPA400")
		aAdd(aFREListFunc,"GTPA004")
		aAdd(aFREListFunc,"GTPA003")
		aAdd(aFREListFunc,"GTPA413")
		aAdd(aFREListFunc,"GTPA414")
		aAdd(aFREListFunc,"GTPA417A")
		aAdd(aFREListFunc,"GTPA417B")
		aAdd(aFREListFunc,"GTPA415")
		aAdd(aFREListFunc,"GTPA418")
		aAdd(aFREListFunc,"GTPA418A")
		aAdd(aFREListFunc,"GTPA401")
		aAdd(aFREListFunc,"GTPA009")
		aAdd(aFREListFunc,"GTPC300N")
		aAdd(aFREListFunc,"GTPA314")
		aAdd(aFREListFunc,"GTPA315")
		aAdd(aFREListFunc,"GTPA316COL")
		aAdd(aFREListFunc,"GTPA316VEI")
		aAdd(aFREListFunc,"GTPA318")
		aAdd(aFREListFunc,"GTPA313")
		aAdd(aFREListFunc,"GTPA302")
		aAdd(aFREListFunc,"GTPA301")
		aAdd(aFREListFunc,"GTPA312")
		aAdd(aFREListFunc,"GTPA303")
		aAdd(aFREListFunc,"GTPA408")
		aAdd(aFREListFunc,"GTPA409")
		aAdd(aFREListFunc,"GTPA300")
		aAdd(aFREListFunc,"GTPA290")
		aAdd(aFREListFunc,"GTPA425")
		aAdd(aFREListFunc,"GTPA311")
		aAdd(aFREListFunc,"GTPA902")
		aAdd(aFREListFunc,"GTPA114")
		aAdd(aFREListFunc,"GTPA110")
		aAdd(aFREListFunc,"GTPA111")
		aAdd(aFREListFunc,"GTPA113")
		aAdd(aFREListFunc,"GTPA112")
		aAdd(aFREListFunc,"GTPA040")
		aAdd(aFREListFunc,"GTPA041")
		aAdd(aFREListFunc,"GTPA042")
		aAdd(aFREListFunc,"GTPA043")
		aAdd(aFREListFunc,"GTPA901")
		aAdd(aFREListFunc,"GTPA900")
		aAdd(aFREListFunc,"GTPA903")
		aAdd(aFREListFunc,"GTPA904")
		aAdd(aFREListFunc,"GTPR118")
		aAdd(aFREListFunc,"GTPR300")
		aAdd(aFREListFunc,"GTPR425")
		aAdd(aFREListFunc,"GTPR302")
		aAdd(aFREListFunc,"GTPR310")
		aAdd(aFREListFunc,"GTPR309")
		aAdd(aFREListFunc,"GTPR307")
		aAdd(aFREListFunc,"GTPR303")
		aAdd(aFREListFunc,"GTPR027")
		aAdd(aFREListFunc,"GTPR302A")
		aAdd(aFREListFunc,"GTPR425B")
		aAdd(aFREListFunc,"GTPR300A")
		aAdd(aFREListFunc,"GTPR110A")
		aAdd(aFREListFunc,"GTPR415")
		aAdd(aFREListFunc,"GTPR418")
		aAdd(aFREListFunc,"GTPR016")
		aAdd(aFREListFunc,"GTPR024")
		aAdd(aFREListFunc,"GTPR017")
		aAdd(aFREListFunc,"GTPA281")
		aAdd(aFREListFunc,"GTPA038")

    EndIf

Return(aFREListFunc)