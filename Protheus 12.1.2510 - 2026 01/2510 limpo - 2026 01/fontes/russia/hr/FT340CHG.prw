Function U_FT340CHG()
Local aRussian   := {'à','á','â','ã','ä','å','¸' ,'æ' ,'ç','è','é','ê','ë','ì','í','î','ï','ð','ñ','ò','ó','ô','õ' ,'ö' ,'÷' ,'ø' ,'ù'   ,'ú','û','ü','ý','þ' ,'ÿ' ,'À','Á','Â','Ã','Ä','Å','¨' ,'Æ' ,'Ç','È','É','Ê','Ë','Ì','Í','Î','Ï','Ð','Ñ','Ò','Ó','Ô','Õ' ,'Ö' ,'×' ,'Ø' ,'Ù'   ,'Ú','Û','Ü','Ý','Þ','ß'}
Local aLatin	 :=	{'a','b','v','g','d','e','yo','zh','z','i','y','k','l','m','n','o','p','r','s','t','u','f','kh','ts','ch','sh','shch','"', 'y',"'",'e','yu','ya','A','B','V','G','D','E','Yo','Zh','Z','I','Y','K','L','M','N','O','P','R','S','T','U','F','Kh','Ts','Ch','Sh','Shch','"','Y',"'",'E','Yu','Ya'}
Local nX := 0
Local cRet := ""
Local nPos := 0
For nX:=1 To Len(ParamIXB[1])
	If (nPos:= Ascan(aRussian,substr(ParamIXB[1],nX,1))) > 0
		cRet += aLatin[nPos]
	Else
		cRet += Substr(ParamIXB[1],nX,1)
	Endif
Next

Return cRet
