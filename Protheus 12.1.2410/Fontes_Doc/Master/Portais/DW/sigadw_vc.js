function preload(imgObj,imgSrc) {
	if (document.images) {
		eval(imgObj+' = new Image()')
		eval(imgObj+'.src = "'+imgSrc+'"')
	}
}

function changeImage(layer,imgName,imgObj) {
	if (document.images) {
		if (document.layers && layer!=null) eval('document.'+layer+'.document.images["'+imgName+'"].src = '+imgObj+'.src')
		else document.images[imgName].src = eval(imgObj+".src")
	}
}

function CheckBox(layer,fldName,trueValue,falseValue,defaultToTrue) {
	this.layer = layer;
	this.imgName = fldName+"_img";
	this.field = document.getElementById(fldName);
	this.trueValue = trueValue;
	this.falseValue = falseValue;
	this.state = (defaultToTrue) ? 1 : 0;
	this.value = (this.state) ? this.trueValue : this.falseValue;
	this.field.value = (this.state) ? this.trueValue : this.falseValue;
	this.field.checked = (this.state) ? true : false;
	this.change = CheckBoxChange;
}

function CheckBoxChange() {
	this.state = (this.state) ? 0 : 1
	this.value = (this.state) ? this.trueValue : this.falseValue
	this.field.value = (this.state) ? this.trueValue : this.falseValue
	this.field.checked = (this.state) ? true : false;
	
	changeImage(this.layer,this.imgName,'checkbox'+this.state)
}