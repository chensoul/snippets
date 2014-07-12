/* Ajax Gold JavaScript Library supports these functions for using Ajax (most commonly used: getDataReturnText and getDataReturnXML) */

function getDataReturnText(url, callback){

/*
this function uses the GET method to get text from the server.
Gets text from url, calls function named callback with that text.
Use when you just want to get data from an URL, or can easily
encode the data you want to pass to the server in an URL, such as
"http://localhost/script.aspx?a=1&b=2".
example: getDataReturnText("http://localhost/data.txt", doWork);
Here, the URL is a string, and doWork is a function in your own script.
*/

	var XMLHttpRequestObject = false;
	if (window.XMLHttpRequest)
		XMLHttpRequestObject = new XMLHttpRequest();
	else if (window.ActiveXObject)
		XMLHttpRequestObject = new ActiveXObject("Microsoft.XMLHTTP");
	
	if(XMLHttpRequestObject) {
		XMLHttpRequestObject.open("GET", url);
		
		XMLHttpRequestObject.onreadystatechange = function(){
			if(XMLHttpRequestObject.readyState == 4 && XMLHttpRequestObject.status == 200){
				callback(XMLHttpRequestObject.responseText);
				delete XMLHttpRequestObject;
				XMLHttpRequestObject = null;
			}
		}
		XMLHttpRequestObject.send(null);
	}
}

function getDataReturnXML(url, callback){

/*
this function uses the GET method to get XML from the server.
Gets XML from url, calls function named callback with that XML.
Use when you just want to get data from an URL, or can easily
encode the data you want to pass to the server in an URL, such as
"http://localhost/script.aspx?a=1&b=2".
example: getDataReturnXML("http://localhost/data.txt", doWork);
Here, the URL is a string, and doWork is a function in your own script.
*/

	var XMLHttpRequestObject = false;
	if (window.XMLHttpRequest)
		XMLHttpRequestObject = new XMLHttpRequest();
	else if (window.ActiveXObject)
		XMLHttpRequestObject = new ActiveXObject("Microsoft.XMLHTTP");
	
	if(XMLHttpRequestObject) {
		XMLHttpRequestObject.open("GET", url);
		
		XMLHttpRequestObject.onreadystatechange = function(){
			if(XMLHttpRequestObject.readyState == 4 && XMLHttpRequestObject.status == 200){
				callback(XMLHttpRequestObject.responseXML);
				delete XMLHttpRequestObject;
				XMLHttpRequestObject = null;
			}
		}
		XMLHttpRequestObject.send(null);
	}
}

function postDataReturnText(url, data, callback){

/*
this function uses the POST method to send data to server, gets text back.
Posts data to url, calls function callback with the returned  text.
Uses the POST method, use this when you have more text data to send to
the server that can be easily encoded into an URL.
example: postDataReturnText("http://localhost/data.aspx", "parameter=5&b=4", doWork);
Here, the URL is a string, the data sent to the server is a string,
and doWork is a function in your own script.
*/

	var XMLHttpRequestObject = false;
	if (window.XMLHttpRequest)
		XMLHttpRequestObject = new XMLHttpRequest();
	else if (window.ActiveXObject)
		XMLHttpRequestObject = new ActiveXObject("Microsoft.XMLHTTP");
	
	if(XMLHttpRequestObject) {
		XMLHttpRequestObject.open("POST", url);
		XMLHttpRequestObject.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
		
		XMLHttpRequestObject.onreadystatechange = function(){
			if(XMLHttpRequestObject.readyState == 4 && XMLHttpRequestObject.status == 200){
				callback(XMLHttpRequestObject.responseText);
				delete XMLHttpRequestObject;
				XMLHttpRequestObject = null;
			}
		}
		XMLHttpRequestObject.send(data);
	}
}

function postDataReturnXML(url, data, callback){

/*
this function uses the POST method to send data to server, gets XML back.
Posts data to url, calls function callback with the returned XML.
Uses the POST method, use this when you have more text data to send to
the server that can be easily encoded into an URL.
example: postDataReturnText("http://localhost/data.aspx", "parameter=5&b=4", doWork);
Here, the URL is a string, the data sent to the server is a string,
and doWork is a function in your own script.
*/

	var XMLHttpRequestObject = false;
	if (window.XMLHttpRequest)
		XMLHttpRequestObject = new XMLHttpRequest();
	else if (window.ActiveXObject)
		XMLHttpRequestObject = new ActiveXObject("Microsoft.XMLHTTP");
	
	if(XMLHttpRequestObject) {
		XMLHttpRequestObject.open("POST", url);
		XMLHttpRequestObject.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
		
		XMLHttpRequestObject.onreadystatechange = function(){
			if(XMLHttpRequestObject.readyState == 4 && XMLHttpRequestObject.status == 200){
				callback(XMLHttpRequestObject.responseXML);
				delete XMLHttpRequestObject;
				XMLHttpRequestObject = null;
			}
		}
		XMLHttpRequestObject.send(data);
	}
}