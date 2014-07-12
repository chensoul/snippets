function Request(l){
	var xhr = createXhr();
	var listener = l;
	if(!listener) listener = new ResponseListener();
	
	this.doGet = function(url,async){
		sendRequest("GET", url, null, async);
	}
	this.doPost = function(url, requestBody, async){
		sendRequest("POST", url, requestBody, async);
	}
	function sendRequest(method, url, requestBody, async){
			if(async == undefined) async = true;
			else if(async) async = true;
			else async = false;
			
			xhr.open(method, url, async);
			if(async) xhr.onreadystatechange = callback;
			xhr.setRequestHeader("Content-Type",
			 "application/x-www-form-urlencoded"
			);
			xhr.send(requestBody);
			if(!async) listener.complete(
			  xhr.status, xhr.statusText, xhr.responseText, xhr.responseXML
			);
	} 
	
	function callback(){
		switch(xhr.readyState){
			case 0: listener.uninitialized(); break;
			case 1: listener.loading(); break;
			case 2: listener.loaded(); break;
			case 3: listener.interactive(); break;
			case 4: listener.complete(
				xhr.status, xhr.statusText, xhr.responseText, xhr.responseXML
			); break;
		}
	}
}

function ResponseListener(){
	this.uninitialized = function(){}
	this.loading = function(){}
	this.loaded = function(){}
	this.interactive = function(){}
	this.complete = function(status, statusText, responseText, responseXML){}
}

function ResponseAdapter(){
	this.handleText = function(text){}
	this.handleXml = function(xml){}
	this.handleError = function(status, statusText){
		alert("Error: " + status + " " + statusText);
	}
	
	this.complete = function(status, statusText, responseText, responseXML){
		if(status == 200){
			this.handleText(responseText);
			this.handleXml(responseXML);
		}else{
			this.handleError(status, statusText);
		}
	}
}

ResponseAdapter.prototype = new ResponseListener();
ResponseAdapter.prototype.constructor = ResponseAdapter;

if(!kettasAjax) var kettasAjax = {};
if(!kettasAjax.getText){
	kettasAjax.getText = function(url, handleText, async){
		var l = new ResponseAdapter();
		l.handleText = handleText;
		var req = new Request(l);
		req.doGet(url, async);
	}
}

if(!kettasAjax.getXml){
	kettasAjax.getXml = function(url, handleXml, async){
		var l = new ResponseAdapter();
		l.handleXml = handleXml;
		var req = new Request(l);
		req.doGet(url, async);
	}
}

if(!kettasAjax.postText){
	kettasAjax.postText = function(url, requestBody,handleText, async){
		var l = new ResponseAdapter();
		l.handleText = handleText;
		var req = new Request(l);
		req.doPost(url,requestBody, async);
	}
}

if(!kettasAjax.postXml){
	kettasAjax.postXml = function(url, requestBody, handleXml, async){
		var l = new ResponseAdapter();
		l.handleText = handleXml;
		var req = new Request(l);
		req.doPost(url, requestBody, async);
	}
}