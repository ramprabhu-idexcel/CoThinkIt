
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



