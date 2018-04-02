/*	SWFObject v2.2 <http://code.google.com/p/swfobject/> 
	is released under the MIT License <http://www.opensource.org/licenses/mit-license.php> 
*/
var swfobject=function(){var D="undefined",r="object",S="Shockwave Flash",W="ShockwaveFlash.ShockwaveFlash",q="application/x-shockwave-flash",R="SWFObjectExprInst",x="onreadystatechange",O=window,j=document,t=navigator,T=false,U=[h],o=[],N=[],I=[],l,Q,E,B,J=false,a=false,n,G,m=true,M=function(){var aa=typeof j.getElementById!=D&&typeof j.getElementsByTagName!=D&&typeof j.createElement!=D,ah=t.userAgent.toLowerCase(),Y=t.platform.toLowerCase(),ae=Y?/win/.test(Y):/win/.test(ah),ac=Y?/mac/.test(Y):/mac/.test(ah),af=/webkit/.test(ah)?parseFloat(ah.replace(/^.*webkit\/(\d+(\.\d+)?).*$/,"$1")):false,X=!+"\v1",ag=[0,0,0],ab=null;if(typeof t.plugins!=D&&typeof t.plugins[S]==r){ab=t.plugins[S].description;if(ab&&!(typeof t.mimeTypes!=D&&t.mimeTypes[q]&&!t.mimeTypes[q].enabledPlugin)){T=true;X=false;ab=ab.replace(/^.*\s+(\S+\s+\S+$)/,"$1");ag[0]=parseInt(ab.replace(/^(.*)\..*$/,"$1"),10);ag[1]=parseInt(ab.replace(/^.*\.(.*)\s.*$/,"$1"),10);ag[2]=/[a-zA-Z]/.test(ab)?parseInt(ab.replace(/^.*[a-zA-Z]+(.*)$/,"$1"),10):0}}else{if(typeof O.ActiveXObject!=D){try{var ad=new ActiveXObject(W);if(ad){ab=ad.GetVariable("$version");if(ab){X=true;ab=ab.split(" ")[1].split(",");ag=[parseInt(ab[0],10),parseInt(ab[1],10),parseInt(ab[2],10)]}}}catch(Z){}}}return{w3:aa,pv:ag,wk:af,ie:X,win:ae,mac:ac}}(),k=function(){if(!M.w3){return}if((typeof j.readyState!=D&&j.readyState=="complete")||(typeof j.readyState==D&&(j.getElementsByTagName("body")[0]||j.body))){f()}if(!J){if(typeof j.addEventListener!=D){j.addEventListener("DOMContentLoaded",f,false)}if(M.ie&&M.win){j.attachEvent(x,function(){if(j.readyState=="complete"){j.detachEvent(x,arguments.callee);f()}});if(O==top){(function(){if(J){return}try{j.documentElement.doScroll("left")}catch(X){setTimeout(arguments.callee,0);return}f()})()}}if(M.wk){(function(){if(J){return}if(!/loaded|complete/.test(j.readyState)){setTimeout(arguments.callee,0);return}f()})()}s(f)}}();function f(){if(J){return}try{var Z=j.getElementsByTagName("body")[0].appendChild(C("span"));Z.parentNode.removeChild(Z)}catch(aa){return}J=true;var X=U.length;for(var Y=0;Y<X;Y++){U[Y]()}}function K(X){if(J){X()}else{U[U.length]=X}}function s(Y){if(typeof O.addEventListener!=D){O.addEventListener("load",Y,false)}else{if(typeof j.addEventListener!=D){j.addEventListener("load",Y,false)}else{if(typeof O.attachEvent!=D){i(O,"onload",Y)}else{if(typeof O.onload=="function"){var X=O.onload;O.onload=function(){X();Y()}}else{O.onload=Y}}}}}function h(){if(T){V()}else{H()}}function V(){var X=j.getElementsByTagName("body")[0];var aa=C(r);aa.setAttribute("type",q);var Z=X.appendChild(aa);if(Z){var Y=0;(function(){if(typeof Z.GetVariable!=D){var ab=Z.GetVariable("$version");if(ab){ab=ab.split(" ")[1].split(",");M.pv=[parseInt(ab[0],10),parseInt(ab[1],10),parseInt(ab[2],10)]}}else{if(Y<10){Y++;setTimeout(arguments.callee,10);return}}X.removeChild(aa);Z=null;H()})()}else{H()}}function H(){var ag=o.length;if(ag>0){for(var af=0;af<ag;af++){var Y=o[af].id;var ab=o[af].callbackFn;var aa={success:false,id:Y};if(M.pv[0]>0){var ae=c(Y);if(ae){if(F(o[af].swfVersion)&&!(M.wk&&M.wk<312)){w(Y,true);if(ab){aa.success=true;aa.ref=z(Y);ab(aa)}}else{if(o[af].expressInstall&&A()){var ai={};ai.data=o[af].expressInstall;ai.width=ae.getAttribute("width")||"0";ai.height=ae.getAttribute("height")||"0";if(ae.getAttribute("class")){ai.styleclass=ae.getAttribute("class")}if(ae.getAttribute("align")){ai.align=ae.getAttribute("align")}var ah={};var X=ae.getElementsByTagName("param");var ac=X.length;for(var ad=0;ad<ac;ad++){if(X[ad].getAttribute("name").toLowerCase()!="movie"){ah[X[ad].getAttribute("name")]=X[ad].getAttribute("value")}}P(ai,ah,Y,ab)}else{p(ae);if(ab){ab(aa)}}}}}else{w(Y,true);if(ab){var Z=z(Y);if(Z&&typeof Z.SetVariable!=D){aa.success=true;aa.ref=Z}ab(aa)}}}}}function z(aa){var X=null;var Y=c(aa);if(Y&&Y.nodeName=="OBJECT"){if(typeof Y.SetVariable!=D){X=Y}else{var Z=Y.getElementsByTagName(r)[0];if(Z){X=Z}}}return X}function A(){return !a&&F("6.0.65")&&(M.win||M.mac)&&!(M.wk&&M.wk<312)}function P(aa,ab,X,Z){a=true;E=Z||null;B={success:false,id:X};var ae=c(X);if(ae){if(ae.nodeName=="OBJECT"){l=g(ae);Q=null}else{l=ae;Q=X}aa.id=R;if(typeof aa.width==D||(!/%$/.test(aa.width)&&parseInt(aa.width,10)<310)){aa.width="310"}if(typeof aa.height==D||(!/%$/.test(aa.height)&&parseInt(aa.height,10)<137)){aa.height="137"}j.title=j.title.slice(0,47)+" - Flash Player Installation";var ad=M.ie&&M.win?"ActiveX":"PlugIn",ac="MMredirectURL="+O.location.toString().replace(/&/g,"%26")+"&MMplayerType="+ad+"&MMdoctitle="+j.title;if(typeof ab.flashvars!=D){ab.flashvars+="&"+ac}else{ab.flashvars=ac}if(M.ie&&M.win&&ae.readyState!=4){var Y=C("div");X+="SWFObjectNew";Y.setAttribute("id",X);ae.parentNode.insertBefore(Y,ae);ae.style.display="none";(function(){if(ae.readyState==4){ae.parentNode.removeChild(ae)}else{setTimeout(arguments.callee,10)}})()}u(aa,ab,X)}}function p(Y){if(M.ie&&M.win&&Y.readyState!=4){var X=C("div");Y.parentNode.insertBefore(X,Y);X.parentNode.replaceChild(g(Y),X);Y.style.display="none";(function(){if(Y.readyState==4){Y.parentNode.removeChild(Y)}else{setTimeout(arguments.callee,10)}})()}else{Y.parentNode.replaceChild(g(Y),Y)}}function g(ab){var aa=C("div");if(M.win&&M.ie){aa.innerHTML=ab.innerHTML}else{var Y=ab.getElementsByTagName(r)[0];if(Y){var ad=Y.childNodes;if(ad){var X=ad.length;for(var Z=0;Z<X;Z++){if(!(ad[Z].nodeType==1&&ad[Z].nodeName=="PARAM")&&!(ad[Z].nodeType==8)){aa.appendChild(ad[Z].cloneNode(true))}}}}}return aa}function u(ai,ag,Y){var X,aa=c(Y);if(M.wk&&M.wk<312){return X}if(aa){if(typeof ai.id==D){ai.id=Y}if(M.ie&&M.win){var ah="";for(var ae in ai){if(ai[ae]!=Object.prototype[ae]){if(ae.toLowerCase()=="data"){ag.movie=ai[ae]}else{if(ae.toLowerCase()=="styleclass"){ah+=' class="'+ai[ae]+'"'}else{if(ae.toLowerCase()!="classid"){ah+=" "+ae+'="'+ai[ae]+'"'}}}}}var af="";for(var ad in ag){if(ag[ad]!=Object.prototype[ad]){af+='<param name="'+ad+'" value="'+ag[ad]+'" />'}}aa.outerHTML='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'+ah+">"+af+"</object>";N[N.length]=ai.id;X=c(ai.id)}else{var Z=C(r);Z.setAttribute("type",q);for(var ac in ai){if(ai[ac]!=Object.prototype[ac]){if(ac.toLowerCase()=="styleclass"){Z.setAttribute("class",ai[ac])}else{if(ac.toLowerCase()!="classid"){Z.setAttribute(ac,ai[ac])}}}}for(var ab in ag){if(ag[ab]!=Object.prototype[ab]&&ab.toLowerCase()!="movie"){e(Z,ab,ag[ab])}}aa.parentNode.replaceChild(Z,aa);X=Z}}return X}function e(Z,X,Y){var aa=C("param");aa.setAttribute("name",X);aa.setAttribute("value",Y);Z.appendChild(aa)}function y(Y){var X=c(Y);if(X&&X.nodeName=="OBJECT"){if(M.ie&&M.win){X.style.display="none";(function(){if(X.readyState==4){b(Y)}else{setTimeout(arguments.callee,10)}})()}else{X.parentNode.removeChild(X)}}}function b(Z){var Y=c(Z);if(Y){for(var X in Y){if(typeof Y[X]=="function"){Y[X]=null}}Y.parentNode.removeChild(Y)}}function c(Z){var X=null;try{X=j.getElementById(Z)}catch(Y){}return X}function C(X){return j.createElement(X)}function i(Z,X,Y){Z.attachEvent(X,Y);I[I.length]=[Z,X,Y]}function F(Z){var Y=M.pv,X=Z.split(".");X[0]=parseInt(X[0],10);X[1]=parseInt(X[1],10)||0;X[2]=parseInt(X[2],10)||0;return(Y[0]>X[0]||(Y[0]==X[0]&&Y[1]>X[1])||(Y[0]==X[0]&&Y[1]==X[1]&&Y[2]>=X[2]))?true:false}function v(ac,Y,ad,ab){if(M.ie&&M.mac){return}var aa=j.getElementsByTagName("head")[0];if(!aa){return}var X=(ad&&typeof ad=="string")?ad:"screen";if(ab){n=null;G=null}if(!n||G!=X){var Z=C("style");Z.setAttribute("type","text/css");Z.setAttribute("media",X);n=aa.appendChild(Z);if(M.ie&&M.win&&typeof j.styleSheets!=D&&j.styleSheets.length>0){n=j.styleSheets[j.styleSheets.length-1]}G=X}if(M.ie&&M.win){if(n&&typeof n.addRule==r){n.addRule(ac,Y)}}else{if(n&&typeof j.createTextNode!=D){n.appendChild(j.createTextNode(ac+" {"+Y+"}"))}}}function w(Z,X){if(!m){return}var Y=X?"visible":"hidden";if(J&&c(Z)){c(Z).style.visibility=Y}else{v("#"+Z,"visibility:"+Y)}}function L(Y){var Z=/[\\\"<>\.;]/;var X=Z.exec(Y)!=null;return X&&typeof encodeURIComponent!=D?encodeURIComponent(Y):Y}var d=function(){if(M.ie&&M.win){window.attachEvent("onunload",function(){var ac=I.length;for(var ab=0;ab<ac;ab++){I[ab][0].detachEvent(I[ab][1],I[ab][2])}var Z=N.length;for(var aa=0;aa<Z;aa++){y(N[aa])}for(var Y in M){M[Y]=null}M=null;for(var X in swfobject){swfobject[X]=null}swfobject=null})}}();return{registerObject:function(ab,X,aa,Z){if(M.w3&&ab&&X){var Y={};Y.id=ab;Y.swfVersion=X;Y.expressInstall=aa;Y.callbackFn=Z;o[o.length]=Y;w(ab,false)}else{if(Z){Z({success:false,id:ab})}}},getObjectById:function(X){if(M.w3){return z(X)}},embedSWF:function(ab,ah,ae,ag,Y,aa,Z,ad,af,ac){var X={success:false,id:ah};if(M.w3&&!(M.wk&&M.wk<312)&&ab&&ah&&ae&&ag&&Y){w(ah,false);K(function(){ae+="";ag+="";var aj={};if(af&&typeof af===r){for(var al in af){aj[al]=af[al]}}aj.data=ab;aj.width=ae;aj.height=ag;var am={};if(ad&&typeof ad===r){for(var ak in ad){am[ak]=ad[ak]}}if(Z&&typeof Z===r){for(var ai in Z){if(typeof am.flashvars!=D){am.flashvars+="&"+ai+"="+Z[ai]}else{am.flashvars=ai+"="+Z[ai]}}}if(F(Y)){var an=u(aj,am,ah);if(aj.id==ah){w(ah,true)}X.success=true;X.ref=an}else{if(aa&&A()){aj.data=aa;P(aj,am,ah,ac);return}else{w(ah,true)}}if(ac){ac(X)}})}else{if(ac){ac(X)}}},switchOffAutoHideShow:function(){m=false},ua:M,getFlashPlayerVersion:function(){return{major:M.pv[0],minor:M.pv[1],release:M.pv[2]}},hasFlashPlayerVersion:F,createSWF:function(Z,Y,X){if(M.w3){return u(Z,Y,X)}else{return undefined}},showExpressInstall:function(Z,aa,X,Y){if(M.w3&&A()){P(Z,aa,X,Y)}},removeSWF:function(X){if(M.w3){y(X)}},createCSS:function(aa,Z,Y,X){if(M.w3){v(aa,Z,Y,X)}},addDomLoadEvent:K,addLoadEvent:s,getQueryParamValue:function(aa){var Z=j.location.search||j.location.hash;if(Z){if(/\?/.test(Z)){Z=Z.split("?")[1]}if(aa==null){return L(Z)}var Y=Z.split("&");for(var X=0;X<Y.length;X++){if(Y[X].substring(0,Y[X].indexOf("="))==aa){return L(Y[X].substring((Y[X].indexOf("=")+1)))}}}return""},expressInstallCallback:function(){if(a){var X=c(R);if(X&&l){X.parentNode.replaceChild(l,X);if(Q){w(Q,true);if(M.ie&&M.win){l.style.display="block"}}if(E){E(B)}}a=false}}}}();

/*
Copyright 2006 Adobe Systems Incorporated
*/

function FABridge(target,bridgeName)
{this.target=target;this.remoteTypeCache={};this.remoteInstanceCache={};this.remoteFunctionCache={};this.localFunctionCache={};this.bridgeID=FABridge.nextBridgeID++;this.name=bridgeName;this.nextLocalFuncID=0;FABridge.instances[this.name]=this;FABridge.idMap[this.bridgeID]=this;return this;}
FABridge.TYPE_ASINSTANCE=1;FABridge.TYPE_ASFUNCTION=2;FABridge.TYPE_JSFUNCTION=3;FABridge.TYPE_ANONYMOUS=4;FABridge.initCallbacks={};FABridge.userTypes={};FABridge.addToUserTypes=function()
{for(var i=0;i<arguments.length;i++)
{FABridge.userTypes[arguments[i]]={'typeName':arguments[i],'enriched':false};}}
FABridge.argsToArray=function(args)
{var result=[];for(var i=0;i<args.length;i++)
{result[i]=args[i];}
return result;}
function instanceFactory(objID)
{this.fb_instance_id=objID;return this;}
function FABridge__invokeJSFunction(args)
{var funcID=args[0];var throughArgs=args.concat();throughArgs.shift();var bridge=FABridge.extractBridgeFromID(funcID);return bridge.invokeLocalFunction(funcID,throughArgs);}
FABridge.addInitializationCallback=function(bridgeName,callback)
{var inst=FABridge.instances[bridgeName];if(inst!=undefined)
{callback.call(inst);return;}
var callbackList=FABridge.initCallbacks[bridgeName];if(callbackList==null)
{FABridge.initCallbacks[bridgeName]=callbackList=[];}
callbackList.push(callback);}
function FABridge__bridgeInitialized(bridgeName){var objects=document.getElementsByTagName("object");var ol=objects.length;var activeObjects=[];if(ol>0){for(var i=0;i<ol;i++){if(typeof objects[i].SetVariable!="undefined"){activeObjects[activeObjects.length]=objects[i];}}}
var embeds=document.getElementsByTagName("embed");var el=embeds.length;var activeEmbeds=[];if(el>0){for(var j=0;j<el;j++){if(typeof embeds[j].SetVariable!="undefined"){activeEmbeds[activeEmbeds.length]=embeds[j];}}}
var aol=activeObjects.length;var ael=activeEmbeds.length;var searchStr="bridgeName="+bridgeName;if((aol==1&&!ael)||(aol==1&&ael==1)){FABridge.attachBridge(activeObjects[0],bridgeName);}
else if(ael==1&&!aol){FABridge.attachBridge(activeEmbeds[0],bridgeName);}
else{var flash_found=false;if(aol>1){for(var k=0;k<aol;k++){var params=activeObjects[k].childNodes;for(var l=0;l<params.length;l++){var param=params[l];if(param.nodeType==1&&param.tagName.toLowerCase()=="param"&&param["name"].toLowerCase()=="flashvars"&&param["value"].indexOf(searchStr)>=0){FABridge.attachBridge(activeObjects[k],bridgeName);flash_found=true;break;}}
if(flash_found){break;}}}
if(!flash_found&&ael>1){for(var m=0;m<ael;m++){var flashVars=activeEmbeds[m].attributes.getNamedItem("flashVars").nodeValue;if(flashVars.indexOf(searchStr)>=0){FABridge.attachBridge(activeEmbeds[m],bridgeName);break;}}}}
return true;}
FABridge.nextBridgeID=0;FABridge.instances={};FABridge.idMap={};FABridge.refCount=0;FABridge.extractBridgeFromID=function(id)
{var bridgeID=(id>>16);return FABridge.idMap[bridgeID];}
FABridge.attachBridge=function(instance,bridgeName)
{var newBridgeInstance=new FABridge(instance,bridgeName);FABridge[bridgeName]=newBridgeInstance;var callbacks=FABridge.initCallbacks[bridgeName];if(callbacks==null)
{return;}
for(var i=0;i<callbacks.length;i++)
{callbacks[i].call(newBridgeInstance);}
delete FABridge.initCallbacks[bridgeName]}
FABridge.blockedMethods={toString:true,get:true,set:true,call:true};FABridge.prototype={root:function()
{return this.deserialize(this.target.getRoot());},releaseASObjects:function()
{return this.target.releaseASObjects();},releaseNamedASObject:function(value)
{if(typeof(value)!="object")
{return false;}
else
{var ret=this.target.releaseNamedASObject(value.fb_instance_id);return ret;}},create:function(className)
{return this.deserialize(this.target.create(className));},makeID:function(token)
{return(this.bridgeID<<16)+token;},getPropertyFromAS:function(objRef,propName)
{if(FABridge.refCount>0)
{throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");}
else
{FABridge.refCount++;retVal=this.target.getPropFromAS(objRef,propName);retVal=this.handleError(retVal);FABridge.refCount--;return retVal;}},setPropertyInAS:function(objRef,propName,value)
{if(FABridge.refCount>0)
{throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");}
else
{FABridge.refCount++;retVal=this.target.setPropInAS(objRef,propName,this.serialize(value));retVal=this.handleError(retVal);FABridge.refCount--;return retVal;}},callASFunction:function(funcID,args)
{if(FABridge.refCount>0)
{throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");}
else
{FABridge.refCount++;retVal=this.target.invokeASFunction(funcID,this.serialize(args));retVal=this.handleError(retVal);FABridge.refCount--;return retVal;}},callASMethod:function(objID,funcName,args)
{if(FABridge.refCount>0)
{throw new Error("You are trying to call recursively into the Flash Player which is not allowed. In most cases the JavaScript setTimeout function, can be used as a workaround.");}
else
{FABridge.refCount++;args=this.serialize(args);retVal=this.target.invokeASMethod(objID,funcName,args);retVal=this.handleError(retVal);FABridge.refCount--;return retVal;}},invokeLocalFunction:function(funcID,args)
{var result;var func=this.localFunctionCache[funcID];if(func!=undefined)
{result=this.serialize(func.apply(null,this.deserialize(args)));}
return result;},getTypeFromName:function(objTypeName)
{return this.remoteTypeCache[objTypeName];},createProxy:function(objID,typeName)
{var objType=this.getTypeFromName(typeName);instanceFactory.prototype=objType;var instance=new instanceFactory(objID);this.remoteInstanceCache[objID]=instance;return instance;},getProxy:function(objID)
{return this.remoteInstanceCache[objID];},addTypeDataToCache:function(typeData)
{var newType=new ASProxy(this,typeData.name);var accessors=typeData.accessors;for(var i=0;i<accessors.length;i++)
{this.addPropertyToType(newType,accessors[i]);}
var methods=typeData.methods;for(var i=0;i<methods.length;i++)
{if(FABridge.blockedMethods[methods[i]]==undefined)
{this.addMethodToType(newType,methods[i]);}}
this.remoteTypeCache[newType.typeName]=newType;return newType;},addPropertyToType:function(ty,propName)
{var c=propName.charAt(0);var setterName;var getterName;if(c>="a"&&c<="z")
{getterName="get"+c.toUpperCase()+propName.substr(1);setterName="set"+c.toUpperCase()+propName.substr(1);}
else
{getterName="get"+propName;setterName="set"+propName;}
ty[setterName]=function(val)
{this.bridge.setPropertyInAS(this.fb_instance_id,propName,val);}
ty[getterName]=function()
{return this.bridge.deserialize(this.bridge.getPropertyFromAS(this.fb_instance_id,propName));}},addMethodToType:function(ty,methodName)
{ty[methodName]=function()
{return this.bridge.deserialize(this.bridge.callASMethod(this.fb_instance_id,methodName,FABridge.argsToArray(arguments)));}},getFunctionProxy:function(funcID)
{var bridge=this;if(this.remoteFunctionCache[funcID]==null)
{this.remoteFunctionCache[funcID]=function()
{bridge.callASFunction(funcID,FABridge.argsToArray(arguments));}}
return this.remoteFunctionCache[funcID];},getFunctionID:function(func)
{if(func.__bridge_id__==undefined)
{func.__bridge_id__=this.makeID(this.nextLocalFuncID++);this.localFunctionCache[func.__bridge_id__]=func;}
return func.__bridge_id__;},serialize:function(value)
{var result={};var t=typeof(value);if(t=="number"||t=="string"||t=="boolean"||t==null||t==undefined)
{result=value;}
else if(value instanceof Array)
{result=[];for(var i=0;i<value.length;i++)
{result[i]=this.serialize(value[i]);}}
else if(t=="function")
{result.type=FABridge.TYPE_JSFUNCTION;result.value=this.getFunctionID(value);}
else if(value instanceof ASProxy)
{result.type=FABridge.TYPE_ASINSTANCE;result.value=value.fb_instance_id;}
else
{result.type=FABridge.TYPE_ANONYMOUS;result.value=value;}
return result;},deserialize:function(packedValue)
{var result;var t=typeof(packedValue);if(t=="number"||t=="string"||t=="boolean"||packedValue==null||packedValue==undefined)
{result=this.handleError(packedValue);}
else if(packedValue instanceof Array)
{result=[];for(var i=0;i<packedValue.length;i++)
{result[i]=this.deserialize(packedValue[i]);}}
else if(t=="object")
{for(var i=0;i<packedValue.newTypes.length;i++)
{this.addTypeDataToCache(packedValue.newTypes[i]);}
for(var aRefID in packedValue.newRefs)
{this.createProxy(aRefID,packedValue.newRefs[aRefID]);}
if(packedValue.type==FABridge.TYPE_PRIMITIVE)
{result=packedValue.value;}
else if(packedValue.type==FABridge.TYPE_ASFUNCTION)
{result=this.getFunctionProxy(packedValue.value);}
else if(packedValue.type==FABridge.TYPE_ASINSTANCE)
{result=this.getProxy(packedValue.value);}
else if(packedValue.type==FABridge.TYPE_ANONYMOUS)
{result=packedValue.value;}}
return result;},addRef:function(obj)
{this.target.incRef(obj.fb_instance_id);},release:function(obj)
{this.target.releaseRef(obj.fb_instance_id);},handleError:function(value)
{if(typeof(value)=="string"&&value.indexOf("__FLASHERROR")==0)
{var myErrorMessage=value.split("||");if(FABridge.refCount>0)
{FABridge.refCount--;}
throw new Error(myErrorMessage[1]);return value;}
else
{return value;}}};ASProxy=function(bridge,typeName)
{this.bridge=bridge;this.typeName=typeName;return this;};ASProxy.prototype={get:function(propName)
{return this.bridge.deserialize(this.bridge.getPropertyFromAS(this.fb_instance_id,propName));},set:function(propName,value)
{this.bridge.setPropertyInAS(this.fb_instance_id,propName,value);},call:function(funcName,args)
{this.bridge.callASMethod(this.fb_instance_id,funcName,args);},addRef:function(){this.bridge.addRef(this);},release:function(){this.bridge.release(this);}};

// Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
// License: New BSD License
// Reference: http://dev.w3.org/html5/websockets/
// Reference: http://tools.ietf.org/html/draft-hixie-thewebsocketprotocol

(function(){if(window.WebSocket)return;var console=window.console;if(!console)console={log:function(){},error:function(){}};if(!swfobject.hasFlashPlayerVersion("9.0.0")){console.error("Flash Player is not installed.");return;}
if(location.protocol=="file:"){console.error("WARNING: web-socket-js doesn't work in file:///... URL "+"unless you set Flash Security Settings properly. "+"Open the page via Web server i.e. http://...");}
WebSocket=function(url,protocol,proxyHost,proxyPort,headers){var self=this;self.readyState=WebSocket.CONNECTING;self.bufferedAmount=0;setTimeout(function(){WebSocket.__addTask(function(){self.__createFlash(url,protocol,proxyHost,proxyPort,headers);});},1);}
WebSocket.prototype.__createFlash=function(url,protocol,proxyHost,proxyPort,headers){var self=this;self.__flash=WebSocket.__flash.create(url,protocol,proxyHost||null,proxyPort||0,headers||null);self.__flash.addEventListener("open",function(fe){try{self.readyState=self.__flash.getReadyState();if(self.__timer)clearInterval(self.__timer);if(window.opera){self.__timer=setInterval(function(){self.__handleMessages();},500);}
if(self.onopen)self.onopen();}catch(e){console.error(e.toString());}});self.__flash.addEventListener("close",function(fe){try{self.readyState=self.__flash.getReadyState();if(self.__timer)clearInterval(self.__timer);if(self.onclose)self.onclose();}catch(e){console.error(e.toString());}});self.__flash.addEventListener("message",function(){try{self.__handleMessages();}catch(e){console.error(e.toString());}});self.__flash.addEventListener("error",function(fe){try{if(self.__timer)clearInterval(self.__timer);if(self.onerror)self.onerror();}catch(e){console.error(e.toString());}});self.__flash.addEventListener("stateChange",function(fe){try{self.readyState=self.__flash.getReadyState();self.bufferedAmount=fe.getBufferedAmount();}catch(e){console.error(e.toString());}});};WebSocket.prototype.send=function(data){if(this.__flash){this.readyState=this.__flash.getReadyState();}
if(!this.__flash||this.readyState==WebSocket.CONNECTING){throw"INVALID_STATE_ERR: Web Socket connection has not been established";}
var result=this.__flash.send(encodeURIComponent(data));if(result<0){return true;}else{this.bufferedAmount=result;return false;}};WebSocket.prototype.close=function(){var self=this;if(!self.__flash)return;self.readyState=self.__flash.getReadyState();if(self.readyState==WebSocket.CLOSED||self.readyState==WebSocket.CLOSING)return;self.__flash.close();self.readyState=WebSocket.CLOSED;if(self.__timer)clearInterval(self.__timer);if(self.onclose){setTimeout(self.onclose,1);}};WebSocket.prototype.addEventListener=function(type,listener,useCapture){if(!('__events'in this)){this.__events={};}
if(!(type in this.__events)){this.__events[type]=[];if('function'==typeof this['on'+type]){this.__events[type].defaultHandler=this['on'+type];this['on'+type]=this.__createEventHandler(this,type);}}
this.__events[type].push(listener);};WebSocket.prototype.removeEventListener=function(type,listener,useCapture){if(!('__events'in this)){this.__events={};}
if(!(type in this.__events))return;for(var i=this.__events.length;i>-1;--i){if(listener===this.__events[type][i]){this.__events[type].splice(i,1);break;}}};WebSocket.prototype.dispatchEvent=function(event){if(!('__events'in this))throw'UNSPECIFIED_EVENT_TYPE_ERR';if(!(event.type in this.__events))throw'UNSPECIFIED_EVENT_TYPE_ERR';for(var i=0,l=this.__events[event.type].length;i<l;++i){this.__events[event.type][i](event);if(event.cancelBubble)break;}
if(false!==event.returnValue&&'function'==typeof this.__events[event.type].defaultHandler)
{this.__events[event.type].defaultHandler(event);}};WebSocket.prototype.__handleMessages=function(){var arr=this.__flash.readSocketData();for(var i=0;i<arr.length;i++){var data=decodeURIComponent(arr[i]);try{if(this.onmessage){var e;if(window.MessageEvent&&!window.opera){e=document.createEvent("MessageEvent");e.initMessageEvent("message",false,false,data,null,null,window,null);}else{e={data:data};}
this.onmessage(e);}}catch(e){console.error(e.toString());}}};WebSocket.prototype.__createEventHandler=function(object,type){return function(data){var event=new WebSocketEvent();event.initEvent(type,true,true);event.target=event.currentTarget=object;for(var key in data){event[key]=data[key];}
object.dispatchEvent(event,arguments);};}
function WebSocketEvent(){}
WebSocketEvent.prototype.cancelable=true;WebSocketEvent.prototype.cancelBubble=false;WebSocketEvent.prototype.preventDefault=function(){if(this.cancelable){this.returnValue=false;}};WebSocketEvent.prototype.stopPropagation=function(){this.cancelBubble=true;};WebSocketEvent.prototype.initEvent=function(eventTypeArg,canBubbleArg,cancelableArg){this.type=eventTypeArg;this.cancelable=cancelableArg;this.timeStamp=new Date();};WebSocket.CONNECTING=0;WebSocket.OPEN=1;WebSocket.CLOSING=2;WebSocket.CLOSED=3;WebSocket.__tasks=[];WebSocket.__initialize=function(){if(WebSocket.__swfLocation){window.WEB_SOCKET_SWF_LOCATION=WebSocket.__swfLocation;}
if(!window.WEB_SOCKET_SWF_LOCATION){console.error("[WebSocket] set WEB_SOCKET_SWF_LOCATION to location of WebSocketMain.swf");return;}
var container=document.createElement("div");container.id="webSocketContainer";container.style.position="absolute";if(WebSocket.__isFlashLite()){container.style.left="0px";container.style.top="0px";}else{container.style.left="-100px";container.style.top="-100px";}
var holder=document.createElement("div");holder.id="webSocketFlash";container.appendChild(holder);document.body.appendChild(container);swfobject.embedSWF(WEB_SOCKET_SWF_LOCATION,"webSocketFlash","1","1","9.0.0",null,{bridgeName:"webSocket"},{hasPriority:true,allowScriptAccess:"always"},null,function(e){if(!e.success)console.error("[WebSocket] swfobject.embedSWF failed");});FABridge.addInitializationCallback("webSocket",function(){try{WebSocket.__flash=FABridge.webSocket.root();WebSocket.__flash.setCallerUrl(location.href);WebSocket.__flash.setDebug(!!window.WEB_SOCKET_DEBUG);for(var i=0;i<WebSocket.__tasks.length;++i){WebSocket.__tasks[i]();}
WebSocket.__tasks=[];}catch(e){console.error("[WebSocket] "+e.toString());}});};WebSocket.__addTask=function(task){if(WebSocket.__flash){task();}else{WebSocket.__tasks.push(task);}};WebSocket.__isFlashLite=function(){if(!window.navigator||!window.navigator.mimeTypes)return false;var mimeType=window.navigator.mimeTypes["application/x-shockwave-flash"];if(!mimeType||!mimeType.enabledPlugin||!mimeType.enabledPlugin.filename)return false;return mimeType.enabledPlugin.filename.match(/flashlite/i)?true:false;};window.webSocketLog=function(message){console.log(decodeURIComponent(message));};window.webSocketError=function(message){console.error(decodeURIComponent(message));};if(!window.WEB_SOCKET_DISABLE_AUTO_INITIALIZATION){if(window.addEventListener){window.addEventListener("load",WebSocket.__initialize,false);}else{window.attachEvent("onload",WebSocket.__initialize);}}})();

/*
http://www.JSON.org/json2.js
2010-03-20
Public Domain.
*/
if(!this.JSON){this.JSON={};}
(function(){function f(n){return n<10?'0'+n:n;}
if(typeof Date.prototype.toJSON!=='function'){Date.prototype.toJSON=function(key){return isFinite(this.valueOf())?this.getUTCFullYear()+'-'+
f(this.getUTCMonth()+1)+'-'+
f(this.getUTCDate())+'T'+
f(this.getUTCHours())+':'+
f(this.getUTCMinutes())+':'+
f(this.getUTCSeconds())+'Z':null;};String.prototype.toJSON=Number.prototype.toJSON=Boolean.prototype.toJSON=function(key){return this.valueOf();};}
var cx=/[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,escapable=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,gap,indent,meta={'\b':'\\b','\t':'\\t','\n':'\\n','\f':'\\f','\r':'\\r','"':'\\"','\\':'\\\\'},rep;function quote(string){escapable.lastIndex=0;return escapable.test(string)?'"'+string.replace(escapable,function(a){var c=meta[a];return typeof c==='string'?c:'\\u'+('0000'+a.charCodeAt(0).toString(16)).slice(-4);})+'"':'"'+string+'"';}
function str(key,holder){var i,k,v,length,mind=gap,partial,value=holder[key];if(value&&typeof value==='object'&&typeof value.toJSON==='function'){value=value.toJSON(key);}
if(typeof rep==='function'){value=rep.call(holder,key,value);}
switch(typeof value){case'string':return quote(value);case'number':return isFinite(value)?String(value):'null';case'boolean':case'null':return String(value);case'object':if(!value){return'null';}
gap+=indent;partial=[];if(Object.prototype.toString.apply(value)==='[object Array]'){length=value.length;for(i=0;i<length;i+=1){partial[i]=str(i,value)||'null';}
v=partial.length===0?'[]':gap?'[\n'+gap+
partial.join(',\n'+gap)+'\n'+
mind+']':'['+partial.join(',')+']';gap=mind;return v;}
if(rep&&typeof rep==='object'){length=rep.length;for(i=0;i<length;i+=1){k=rep[i];if(typeof k==='string'){v=str(k,value);if(v){partial.push(quote(k)+(gap?': ':':')+v);}}}}else{for(k in value){if(Object.hasOwnProperty.call(value,k)){v=str(k,value);if(v){partial.push(quote(k)+(gap?': ':':')+v);}}}}
v=partial.length===0?'{}':gap?'{\n'+gap+partial.join(',\n'+gap)+'\n'+
mind+'}':'{'+partial.join(',')+'}';gap=mind;return v;}}
if(typeof JSON.stringify!=='function'){JSON.stringify=function(value,replacer,space){var i;gap='';indent='';if(typeof space==='number'){for(i=0;i<space;i+=1){indent+=' ';}}else if(typeof space==='string'){indent=space;}
rep=replacer;if(replacer&&typeof replacer!=='function'&&(typeof replacer!=='object'||typeof replacer.length!=='number')){throw new Error('JSON.stringify');}
return str('',{'':value});};}
if(typeof JSON.parse!=='function'){JSON.parse=function(text,reviver){var j;function walk(holder,key){var k,v,value=holder[key];if(value&&typeof value==='object'){for(k in value){if(Object.hasOwnProperty.call(value,k)){v=walk(value,k);if(v!==undefined){value[k]=v;}else{delete value[k];}}}}
return reviver.call(holder,key,value);}
text=String(text);cx.lastIndex=0;if(cx.test(text)){text=text.replace(cx,function(a){return'\\u'+
('0000'+a.charCodeAt(0).toString(16)).slice(-4);});}
if(/^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g,'@').replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,']').replace(/(?:^|:|,)(?:\s*\[)+/g,''))){j=eval('('+text+')');return typeof reviver==='function'?walk({'':j},''):j;}
throw new SyntaxError('JSON.parse');};}}());

// Set URL of your WebSocketMain.swf here:
WEB_SOCKET_SWF_LOCATION = "/javascripts/socky/WebSocketMain.swf";
// Set this to dump debug message from Flash to console.log:
WEB_SOCKET_DEBUG = false;

Socky = function(host, port, params) {
  this.host = host;
  this.port = port;
  this.params = params;
  this.connect();
};

// Socky states
Socky.CONNECTING = 0;
Socky.AUTHENTICATING = 1;
Socky.OPEN = 2;
Socky.CLOSED = 3;
Socky.UNAUTHENTICATED = 4;

Socky.prototype.connect = function() {
  var instance = this;
  instance.state = Socky.CONNECTING;

  var ws = new WebSocket(this.host + ':' + this.port + '/?' + this.params);
  ws.onopen    = function()    { instance.onopen(); };
  ws.onmessage = function(evt) { instance.onmessage(evt); };
  ws.onclose   = function()    { instance.onclose(); };
  ws.onerror   = function()    { instance.onerror(); };
};



// ***** Private methods *****
// Try to avoid any modification of these methods
// Modification of these methods may cause script to work invalid
// Please see 'public methods' below
// ***************************

// Called when connection is opened
Socky.prototype.onopen = function() {
  this.state = Socky.AUTHENTICATING;
	this.respond_to_connect();
};

// Called when socket message is received
Socky.prototype.onmessage = function(evt) {
  try {
    var request = JSON.parse(evt.data);
    switch (request.type) {
      case "message":
        this.respond_to_message(request.body);
        break;
      case "authentication":
        if(request.body == "success") {
					this.state = Socky.OPEN;
          this.respond_to_authentication_success();
        } else {
					this.state = Socky.UNAUTHENTICATED;
          this.respond_to_authentication_failure();
        }
        break;
    }
  } catch (e) {
    console.error(e.toString());
  }
};

// Called when socket connection is closed
Socky.prototype.onclose = function() {
  if(this.state != Socky.CLOSED && this.state != Socky.UNAUTHENTICATED) {
    this.respond_to_disconnect();
  }
};

// Called when error occurs
// Currently unused
Socky.prototype.onerror = function() {};



// ***** Public methods *****
// These methods can be freely modified.
// The change should not affect the normal operation of the script.
// **************************

// Called after connection but before authentication confirmation is received
// At this point user is still not allowed to receive messages
Socky.prototype.respond_to_connect = function() {
};

// Called when authentication confirmation is received.
// At this point user will be able to receive messages
Socky.prototype.respond_to_authentication_success = function() {
};

// Called when authentication is rejected by server
// This usually means that secret is invalid or that authentication server is unavailable
// This method will NOT be called if connection with Socky server will be broken - see respond_to_disconnect
Socky.prototype.respond_to_authentication_failure = function() {
};

// Called when new message is received
// Note that msg is not sanitized - it can be any script received.
Socky.prototype.respond_to_message = function(msg) {
  eval(msg);
};

// Called when connection is broken between client and server
// This usually happens when user lost his connection or when Socky server is down.
// At default it will try to reconnect after 1 second.
Socky.prototype.respond_to_disconnect = function() {
	setTimeout(function(instance) { instance.connect(); }, 1000, this);
};


function play_sound() {
	
//var sound_file = document.getElementById('sound1');
	
//	sound_file.Play();
	
	
document.getElementById('testing_beep').innerHTML ='';

document.getElementById('testing_beep').innerHTML= '<embed src="/receive.wav" autostart="true" width="0" height="0" id="sound1" enablejavascript="true" pluginspage="http://www.apple.com/quicktime/download/" type="video/quicktime" >';
	
//document.getElementById('testing_beep').innerHTML= '<embed src="https://cothink-production.s3.amazonaws.com/receive.wav" autostart="true" width="0" height="0" id="sound1" enablejavascript="true" pluginspage="http://www.apple.com/quicktime/download/" type="video/quicktime" >';	

//  document.getElementById('testing_beep').innerHTML= '<embed height=1 width=1 src="https://cothink-production.s3.amazonaws.com/receive.wav" autostart="true" loop="false">';


  
}

$.message_counter = 0;
$.prev_user="";
$.prev_id="";
$.alt="";
Socky.prototype.respond_to_message = function(msg) {
	var data;
  var user_name="";
	var user_class="";
  var user="";
  var message="";
  var time="";
  var color="";
	var count = $.message_counter++;	
	var message_id = 'message-' + count;
	data = JSON.parse(msg);	
  if(data[0]=="project_status")
  { 
    if($(data[1]))
    {
      var alt=$(data[1]).getAttribute('class').include('alt')
      $(data[1]).setAttribute("class","newmessages"+(alt ? " alt" : ""))
    }
  }
  else if(data[0]=="message")
  {
 // document.getElementById('testing_beep').style.display='block';	
  user_name="<span class='author'>"+data[1]+"</span>";
  (data[4]=="") ? color="#ffffff" : color="#"+data[4] ;
  user_class="<div class='chat-row a3' style='background-color:"+color+"' id='chat"+data[3]+"'><div class='box-top'></div><div class='box-top-right'></div>";
  if($.prev_user==data[3])
  {
    $('chat'+data[3]).setAttribute("class", "chat-row a3 same-author ");
  }
  else
  {
    if($.message_counter>1)
    {
      if($.alt=="")
      {
        $.alt="alt";
      }
      else
      {
        $.alt="";
      }
    }
  }
  $.prev_user=data[3]
  message="<div class='chat-log-msg "+$.alt+"'>"+data[2]+"</div>";
  if($('user'+data[3]))
  {
    $('user'+data[3]).setAttribute('class','newmessages alt')
  }
  if(document.getElementById('sound_notification') && document.getElementById('sound_notification').value=="true")
  {
		
    var re = new RegExp($('user_name').value,'i');
    if(data[2].match(re))
    {
      play_sound();
    }
  }
  time="<div class='timestamp'>few seconds ago</div><div class='box-bottom-right'></div><div class='box-bottom'></div></div>";
  if($('log-arrow'))
  {
    $('log-arrow').style.display="block";
  }
  Insertion.Top('cha-information', user_class+user_name+message+time);
  var online_users=""
  if(data[6].length>1)
  { 
    online_users=data[7]
    for(i=0;i<data[6].length;i++)
    {
      if((data[6][i][1])!=$('current_user_id').value)
      {
        online_users+=data[6][i][0]
      }
    }
    online_users+="</ul>"
    if($('show_online') && $('settings_head'))
    {
      $('show_online').innerHTML=online_users;
      $('settings_head').setAttribute('style',"");    
    }
  }
  else
  {
    if($('show_online') && $('settings_head'))
    {
      $('show_online').innerHTML="";
      $('settings_head').style.backgroundPosition="0 0";
    }
  }
	new Effect.Opacity(message_id, { from: 0.0, to: 1.0, duration: 0.5 });
	var messages = document.getElementById("cha-information");
	messages.scrollTop = messages.scrollHeight;
  }
  else if(data[0]=="status")
  {
  }
}



