function form_submit(url, method, id) {
	this.url = url;
	this.method = method;
	new Ajax.Request(this.url, {method: this.method, parameters:$(id).serialize(true),   evalScripts: true, onLoading: displaySpinner(), onSuccess: hideSpinner()});
}

function login(url, method) {
	this.url = url;
	this.method = method;  
	
	new Ajax.Request(this.url, {method: "'" + this.method + "'", parameters:$('login_form').serialize(true),  evalScripts: true, onLoading: displaySpinner(), onSuccess: hideSpinner()});	
}


  function displaySpinner(){
		if($('spinner'))
			$('spinner').show();
  }

  function hideSpinner(){
		if($('spinner'))
		 $('spinner').hide();
  }



function form_submit_register(url, method, id,pwd,cpwd) {
	this.url = url;
	this.method = method;
  $(cpwd).value	=  $(pwd).value 
	new Ajax.Request(this.url, {method: "'" + this.method + "'", parameters:$(id).serialize(true),   evalScripts: true, onLoading: displaySpinner(), onSuccess: hideSpinner()});
}

function validate_registration(actionname) {
	var math_arr = new Array();
	math_arr = [['2 + 3',5], ['1 + 3',4], ['8 - 2',6], ['10 + 1',11], ['3 + 6',9]]	

  error_flag = false;
	if($('user_firstname').value.strip() == "") {
	//	$('firstname').innerHTML="<font color='red'>Please provide Firstname</font>";
		$('firstname').innerHTML="<span class='errmsg'>First Name</span>";
	  error_flag = true;	
	}
	else 
	$('firstname').innerHTML = "First Name";	

	if((actionname == 'new') || (actionname == 'edit' && ($('user_password').value != ''))) {
		if($('user_password').value.strip() == "") {
			$('password').innerHTML="<span class='errmsg'>Password</span>";
			error_flag = true;	
		}
		else {
		if(($('user_password').value.strip().length < 6) || ($('user_password').value.strip().length > 100)) {
			$('password').innerHTML="<span class='errmsg'>Password</span>";
			error_flag = true;	
		}
		else 
			$('password').innerHTML="Password";
		}	
	}
	
	var emailval=$('user_email').value.strip();
  emailCheck = new RegExp(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
	if(emailval.match(emailCheck)==null){
		$('email').innerHTML="<span class='errmsg'>Email</span>";
		error_flag = true;	
	}
	else
	  $('email').innerHTML="Email";
		
	if(actionname == 'new') {
	  if($('existing_emails') != null) {
			var existingemails = $('existing_emails').value.split(',');	
			for (i=0;i<existingemails.length;i++){
				if(existingemails[i]==emailval) {
					error_flag = true;
					$('email').innerHTML="<span class='errmsg'>Email</span>";
				}
			}
		}
	}
	
	if($('user_network_id') != '') {
		var emailext = $('email_ext').value.strip();		
		emailvalext = emailval.split('@')
		if(emailext!=emailvalext[1]) {
		  error_flag = true;
		//	$('email').innerHTML="<font color='red'>Email extension should be same as network domain "+$('email_ext').value.strip()+".</font>";
			$('email').innerHTML="<span class='errmsg'>Email</span>";
		}
	}	
	
	if($('banned_emails') != null) {
		var bannedemails = $('banned_emails').value.split(',');
		for (i=0;i<bannedemails.length;i++){
			if(bannedemails[i]==emailval) {
				error_flag = true;
				$('email').innerHTML="<span class='errmsg'>Email</span>";
			}
		}
	}
	
	if(actionname == 'new') {	
		var confirmemail=$('user_email_confirmation').value.strip();
		if(confirmemail == emailval) 	
				$('email_confirmation').innerHTML="Confirm-email";
			else {		
				$('email_confirmation').innerHTML="<span class='errmsg'>Confirm-email</span>";
				error_flag = true;
			}	
	}	
  if($('user_network_id').value.strip() == "") {
		$('network_id').innerHTML="<span class='errmsg'>Network</span>";
	  error_flag = true;
	}
	else
		$('network_id').innerHTML="Network";
		
/*		
	if($('user_vertical_id').value == "") {
		$('vertical_id').innerHTML="<font color='red'>Please select Vertical</font>";
	  error_flag = true;	
	}
	else
	$('vertical_id').innerHTML = "";		
	*/
	
	var extn = $('image').value.split('.').last()
	if((actionname == 'new') || (actionname == 'edit' && ($('image').value != ''))) {
		if ( extn == "jpg" || extn == "JPG" || extn == "GIF" || extn == "gif" || extn == "jpeg" || extn == "JPEG" || extn == "png" || extn == "PNG" )
			$('image_error_msg').innerHTML="Profile Picture";
		else {
			//$('image_error_msg').innerHTML="<font color='red'>Image must be in .jpg, .gif, .jpeg, .png</font>";
			$('image_error_msg').innerHTML="<span class='errmsg'>Profile Picture</span>";
			error_flag = true;		
		}
	}
	
	if(actionname == 'new') {
		for(l=0; l<5;l++){
			if($('math_ques').innerHTML == math_arr[l][0]) 
				var math_index = l;				
		}		
		
		if($('math_ans').value != math_arr[math_index][1]) {
			rand = randomnum(math_index);		
			$('math_ques').innerHTML = math_arr[rand][0];
			$('math_ans').value = "";
			error_flag = true;	
		}
		else
			$('math_ans').value = "";
	}	
	
	if(error_flag == true) {
		$('err').style.visibility = "visible";
		return false;	
	}
	else {
		$('err').style.visibility = "hidden";
		return true;
	}
}

function randomnum(math_index) {
	var rand = Math.round(Math.random() * 4);		
	
	if(math_index == rand) {
		rand = randomnum(math_index);
		return rand;
	}
	else {
		return rand;
	}
}


function clipboardcopy() {
  if (window.clipboardData) {
    window.clipboardData.setData("Text",$('campus_url').innerHTML);
  }
}
