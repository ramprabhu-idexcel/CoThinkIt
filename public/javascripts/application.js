// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults



function add_user(id)
{

if($(id))
  {
    $(id).checked=true;
  }
}

function remove_user(id)
{
var chk_box=id.childNodes[0].childNodes[0].childNodes[0].childNodes[0].childNodes[0];
if(chk_box)
{
$(chk_box.value).checked=false;
}
return true;
}

function next_month(y,m)
{
  new Ajax.Request('/home/next_month', {method: 'get',parameters: {year: y, month: m}});
}

function previous_month(y,m)
{
  new Ajax.Request('/home/previous_month', {method: 'get',parameters: {year: y, month: m}});
}

function next_month_project(y,m,p)
{
  new Ajax.Request('/dashboard/'+ p + '/next_month', {method: 'get',parameters: {year: y, month: m}});
}

function previous_month_project(y,m,p)
{
  new Ajax.Request('/dashboard/'+ p + '/previous_month', {method: 'get',parameters: {year: y, month: m}});
}

function show_event(i)
{
  new Ajax.Request('/home/show_event/', {method: 'get',parameters: 'date='+i});
}

function show_date(i)
{
  new Ajax.Request('/home/show_date/', {method: 'get',parameters: 'date='+i});
}

function show_event_project(i,p)
{
  new Ajax.Request('/dashboard/' + p +'/show_event/', {method: 'get',parameters: 'date='+i});
}

function expand_task()
{
  $('more_tasks').style.visibility ='visible'; 
  $('more_tasks').style.display ='block'; 
  $('more_task_link').style.visibility ='hidden'; 
}

function expand_todos()
{
  $('more_todos').style.visibility ='visible'; 
  $('more_todos').style.display ='block'; 
  $('todos_link').style.visibility ='hidden'; 
}

function check_visible(){
	if ($('expand').className == "expand-down"){
		$('history_display').show();
	}else{
		$('history_display').hide();
	}
}


function check_visible_for_comment_history(comment){
	if ($('expand_'+comment).className == "expand-down"){
		$('history_display_'+comment).show();
	}else{
		$('history_display_'+comment).hide();
	}
}

function remove_content_date()
{
		var ed = tinyMCE.get('comment_comment');
		ed.setContent('');
	  document.getElementById("status_flag_comment").checked = 0;
	//  document.getElementById('comment_error').innerHTML = '';
}

function remove_content_date_task_todo()
{
		var ed = tinyMCE.get('comment_comment');
		ed.setContent('');
	  //document.getElementById("status_flag_comment").checked = 0;
	//  document.getElementById('comment_error').innerHTML = '';
}

function display_rem_events(date, id)
{
for(i=10; i<id; i++)
{
if($(date+'_'+i))
$(date+'_'+i).show();
}
$(date).hide();
//document.getElementById('hello').style.display="block";
}

function close_control_model()
{
 Control.Modal.close();return false;
}

function guest_user_alert()
{
  alert(" You didn't have permission for this functionality")	
}

function suspend_alert()
{
  alert("Your project has been suspended. Please contact us for more information at support@cothinkit.com")	
}

function completed_alert()
{
	alert("This project has been completed. To resume the project, please change the status of the project in the project settings page.")
}


function suspend_alert_check_box(element_id)
{
	if (document.getElementById(element_id).checked == 1)
	   document.getElementById(element_id).checked = 0
	else
	   document.getElementById(element_id).checked = 1
  alert(" Your project has been suspended. Please contact us for more information at support@cothinkit.com");	
}


function guest_user_alert_check_box(element_id)
{
	if (document.getElementById(element_id).checked == 1)
	   document.getElementById(element_id).checked = 0
	else
	   document.getElementById(element_id).checked = 1
  alert(" You didn't have permission for this functionality");	
}


function previous_month_for_task_todo(y,m)
{
  new Ajax.Request('/search/previous_month', {method: 'get',parameters: {year: y, month: m}});
}

function next_month_for_task_todo(y,m)
{
  new Ajax.Request('/search/next_month', {method: 'get',parameters: {year: y, month: m}});
}

function previous_month_for_task_todo_with_id(y,m,id)
{
  new Ajax.Request('/search/previous_month', {method: 'get',parameters: {year: y, month: m, id:id}});
}

function next_month_for_task_todo_with_id(y,m,id)
{
  new Ajax.Request('/search/next_month', {method: 'get',parameters: {year: y, month: m, id:id}});
}

function select_date_for_task(d)
{
 

document.getElementById('date_display').value	= d; 
document.getElementById('update_calender').style.display = 'none'	; 	
	
}

function select_date_for_task_with_id(d,id)
{
 

document.getElementById('date_display_'+id).value	= d; 
document.getElementById('update_calender_'+id).style.display = 'none'	; 	
	
}

function upgrade(valid,plan_id,change_plan,current_plan)
{
  if(change_plan=="true")
  {
    if(valid=="true")
    { 
      if(current_plan<plan_id)
      {alert("Plan will be downgraded using your previous billing details");}
      else
      {alert("Plan will be upgraded using your previous billing details");
      }
      new Ajax.Request('/users/change_plan', {onLoading: function() {Element.show('spinner')},onComplete:function(){Element.hide('spinner')},method: 'get',parameters: {plan_id: plan_id}});
    }  
    else
    {
      $('plan_id').value=plan_id;
      alert("Please update your Billing Informations and Credit Card details");
       new Ajax.Request('/users/change_plan', {onLoading: function() {Element.show('spinner')},onComplete:function(){Element.hide('spinner')},method: 'get',parameters: {plan_id: plan_id}});
    }
  }
  else
  {
    alert("Sorry, You have crossed the limit. Unable to change your plan")
  }
}

function store_message_js()
{
is_file=document.getElementById('files_list').innerHTML;
if(is_file=="")
{
var proj=document.getElementById('project_id').value;
var url = "/chat/"+proj+"/file_upload";
var mess=document.getElementById('userMessage').value;
var pars = "userMessage=" + mess  + "&project_id=" + proj;
//sendMessageWithCallbacksFromInputField();
var target = 'idresult';
var myAjax = new Ajax.Updater(target,url, {method: 'post',parameters: pars});
}
else
{
document.forms["myform"].submit();
}
}

function clear_data()
{

document.getElementById('userMessage').value="";
document.getElementById('file_upload').style.display="none";
}

function show_upload_form()
{
document.getElementById('file_upload').style.display="block";
}

function more_chat_log()
{
  document.getElementById("chat_more").style.display="none";
  document.getElementById("more_chat_logs").style.display="block";
}

function sound_notification_setting()
{
val=document.getElementById('sound_notification').value;
if(val=="true")
{
  document.getElementById('sound_notification').value="false";
  document.getElementById('apply_sound').innerHTML='<a href="javascript:sound_notification_setting();">Sound Notifications Off</a>';	
}
else
{
  document.getElementById('sound_notification').value="true";
  document.getElementById('apply_sound').innerHTML='<a href="javascript:sound_notification_setting();">Sound Notifications On</a>';
}


}


function play_sound() {


}

function completed_think(name,todo_name){
 document.getElementById(name).className="strike"
	document.getElementById(todo_name).checked= true
}
 
function uncompleted_think(name,todo_name){
		document.getElementById(name).className=" "
		document.getElementById(todo_name).checked= false

}


function show_achieve_part(div_name){
	if (document.getElementById(div_name).style.display=='none'){
		  document.getElementById(div_name).style.display='block';
		}	
}
	
function hide_achieve_part(div_name){
	if (document.getElementById(div_name).style.display=='block'){
		  document.getElementById(div_name).style.display='none';
		}		
}	

function convert_url_to_link(text)
{

if( !text ) return text;
	
text = text.replace(/((https?\:\/\/|ftp\:\/\/)|(www\.))(\S+)(\w{2,4})(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/gi,function(url){	
	nice = url;
	if( url.match('^https?:\/\/') )
	{
	nice = nice;//.replace(/^https?:\/\//i,'')
	}
	else
	url = 'http://'+url;
	
	return '<a target="_blank"  href="'+ url +'">'+ nice+'</a>';

});
return text;
}


function store_content(editor_id)
{
	
//		var ed = tinyMCE.get(editor_id);	
//	  var val = convert_url_to_link(ed.getContent());
	// document.getElementById(editor_id+"_value").value = val;

	
}

function store_content_in_chat(editor_id)
{
	  
		var ed = document.getElementById(editor_id);	
	  var val = ed.value;
	 document.getElementById("message_value").value = val;
	
	
}

function check_valid()
{
  if($('user_password').value.strip()=="" || $('user_password_confirmation').value.strip()=="")
  {
    alert('Password cannot be empty');
    return false
  }
  else
  return true;
}

/* method to display the filename in the modal*/
function display_filename()
{
  var image=['jpg','png','gif','jpeg'];
  var type;
  var file_name=$('upload_file').value;
  var startIndex = (file_name.indexOf('\\') >= 0 ? file_name.lastIndexOf('\\') : file_name.lastIndexOf('/'));
  var filename = file_name.substring(startIndex);
  if (filename.indexOf('\\') === 0 || filename.indexOf('/') === 0)
  {filename = filename.substring(1);}
  type=filename.split('.');
  if(type.length>1)
  {
    var file_type=type[1];
  }
  else
  {
    var file_type=type[0];
  }
  if(image.indexOf(file_type.toLowerCase())>=0)
  {
    $('filename').style.backgroundImage='url(/images/doctype_icons/document-png.png)';
  }
  else
  {
    $('filename').style.backgroundImage='url(/images/doctype_icons/document.png)';
  }
  $('filename').style.backgroundRepeat='no-repeat';
  if(filename.length>29)
  {
    filename=filename.substring(0,26)+"..."
  }
  $('filename').innerHTML=filename;
  return false;
}

function fetch(uuid) {
 req = new XMLHttpRequest();
 req.open("GET", "/progress?X-Progress-ID=" + uuid, 1);
 req.setRequestHeader("X-Progress-ID", uuid);
 req.onreadystatechange = function () {
  if (req.readyState == 4) {
   if (req.status == 200) {
    /* poor-man JSON parser */
    var upload = req.responseText.evalJSON();
    /* change the width if the inner progress-bar */
    if (upload.state == 'done' || upload.state == 'uploading') {
      w = (132 * upload.received / upload.size)-132;
      $('progress_status').innerHTML=upload.state;
      if(w==0)
      {
        w=1;
        $('progress_status').innerHTML="done";
      }
      $('progress').style.backgroundPosition=w+"px 3px" ;
    }
    /* we are done, stop the interval */
    if (upload.state == 'done') {
      $('progress').hide();
      $('progress').style.backgroundPosition="1px 3px" ;
      $('progress_status').hide();
      $('progress').style.backgroundPosition="-132px 3px" ;
      window.clearTimeout(interval);
    }
   }
  }
 }
 req.send(null);
}


function comment_progress_bar(path) {
 /* generate random progress-id */
 if(tinyMCE.get('comment_comment').getContent()!="")
 {
  $('progress').style.backgroundPosition="-132px 3px" ;
  if($('files_list').childElements().length>0)
  {
    $('progress').show();
    $('progress_status').innerHTML="";
    $('progress_status').show();
    var uuid = "";
     for (i = 0; i < 32; i++) {
      uuid += Math.floor(Math.random() * 16).toString(16);
     }
   /* patch the form-action tag to include the progress-id */
    document.getElementById("upload").action=path+"?X-Progress-ID=" + uuid;

     /* call the progress-updater every 1000ms */
    interval = window.setInterval(
      function () {
        fetch(uuid);
      },
      1000
     );
    }
    else
    {
      $("upload").action=path;
    }
  }
  else
  {
    alert("Please enter the comment");
    return false;
  }
}



 function download_bandwidth_check_file_common(id,status)
{
		var check=status;
  
		if (check=="true")
		{
			document.location.href ="/users/download/"+id;
		}
		else
		{
      $('account-limit-modal').show();
		}
}