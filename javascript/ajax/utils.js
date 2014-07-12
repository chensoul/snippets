function createXhr(){
	if(window.ActiveXObject){
		return new ActiveXObject("Microsoft.XMLHTTP");
	}else if(window.XMLHttpRequest){
		return new XMLHttpRequest();
	}else{
		throw new Error("Does not ajax programming");
	}
}

function $(id){
	return byId(id);
}
function byId(id){
	return document.getElementById(id);
}

function getSelectValue(id){
	var select = byId(id);
	var options = select.getElementsByTagName("option");
	for(var i = 0; i < options.length; i++){
		var option = options[i];
		if(option.selected){
			return option.value;
		}
	}
}

function getSelectValues(id){
	var values = [];
	var select = byId(id);
	var options = select.getElementsByTagName("option");
	var j = 0;
	for(var i = 0; i < options.length; i++){
		var option = options[i];
		if(option.selected){
			values[j] = option.value;
			j++;
		}
	}
	return values;
}

function getEavById(id, el){
	if(el) return el.getElementById(id).value;
	return byId(id).value;
}
function getEtvById(id, el){
	if(el) return el.getElementById(id).firstChild.nodeValue;
	return byId(id).firstChild.nodeValue;
}
function getEavByName(name, el){
	if(el) return el.getElementsByTagName(name)[0].value;
	return document.getElementsByTagName(name)[0].value;
}
function getEtvByName(name, el){
	if(el) return el.getElementsByTagName(name)[0].firstChild.nodeValue;
	return document.getElementsByTagName(name)[0].firstChild.nodeValue;
}

//object from form
function obj4form(formId){
	var form = $(formId);
	if(!form) return null;
	var inputs = form.getElementsByTagName("input");
	if(!inputs) return null;
	
	var ret = {};
	for(var i = 0; i < inputs.length; i++){
		var input = inputs[i];
		if(input.name){
			if(input.value){
				ret[input.name] = input.value;
			}else{
				ret[input.name] = null;
			}
		}else if(input.id){
			if(input.value){
				ret[input.id] = input.value;
			}else{
				ret[input.id] = null;
			}
		}
	}

	return ret;
}

//query string from form
function qs4form(formId){
	var qs = "";
	var form = $(formId);
	if(!form) return qs;
	var inputs = form.getElementsByTagName("input");
	
	if(inputs){
		var len = inputs.length;
		for(var i = 0; i < len; i++){
			var input = inputs[i];
			if(input.name){
				if(qs && i >0 && i < len - 1)
					qs += "&";
				qs += input.name + "=" + escape(input.value);
			} else if(input.id){
				if(qs && i >0 && i < len - 1)
					qs += "&";
				qs += input.id + "=" + escape(input.value);
			}else{
				continue;
			}
		}
	}
	return qs;
}