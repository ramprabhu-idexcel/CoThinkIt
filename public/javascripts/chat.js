jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})
 var previous_user;
var old_id;

//String.prototype.endsWith   = function( str ) { return ( this.match( str + "$" ) == str ) }
//String.prototype.startsWith = function( str ) { return ( this.match( "^" + str ) == str ) }
/*
String.prototype.ltrim = function( chars ) { chars = chars || "\\s"; return this.replace( new RegExp( "^[" + chars + "]+",  "g" ), "" ); }
String.prototype.rtrim = function( chars ) { chars = chars || "\\s"; return this.replace( new RegExp( "["  + chars + "]+$", "g" ), "" ); }
String.prototype.trim  = function( chars ) { return this.rtrim( chars).ltrim( chars ); }
*/


/*
String.prototype.containsLink = function( ) {
	var url_match_1 = new RegExp( "https?:\\/\\/([-\\w\\.]+)+(:\\d+)?(\\/([\\w/_\\.]*(\\?\\S+)?)?)?" );
	var url_match_2 = new RegExp( "(^|[^\\w]+)www(:\\d+)?\.(\\/([\\w/_\\.]*(\\?\\S+)?)?)?" );
	return url_match_1.test( this ) || url_match_2.test( this );
}
*/

String.prototype.str_replace = function( find, replacement ) {
	var temp = this.split( find );
	return temp.join( replacement );
}

String.prototype.to_href = function( ) {
	var lower = this.toLowerCase( );
	if( !lower.startsWith( 'http://' ) && !lower.startsWith( 'https://' ) )
		return 'http://' + this;
	else
		return this;
}

String.prototype.extractLink = function( ) {
	var url_match_1 = new RegExp( "(https?:\\/\\/(?:[\\w/-]*\\.+[\\w/-]+)+(?:[\\w/_\\.]*(?:\\?\\S+)?)?)" );
	var result = url_match_1.exec( this );
	if( !result )
	{
		var url_match_2 = new RegExp( "(?:^|[^\\w]+)(www\.(?:(?:[\\w/-]*\\.+[\\w/-]+)+(?:[\\w/_\\.]*(?:\\?\\S+)?)?)+)" );
		result = url_match_2.exec( this );
		if( result ) {
			return result[ 0 ];
		} else
			return false;
	}
	else
		return result[ 0 ];
}

String.prototype.extractEmbedded = function( ) {

	var new_width = 530;
	var content = this;
	var extracted = Array( );
// I have commented this line, since it is not working in firefox, well may be need to find the reason why not working
	//content = content.unescapeHTML( ).strip( );

	var url_match_1 = new RegExp( "<embed.+src=['\\\"]?([^'\\\"\\s]+)['\\\"\\s]?.+(</embed>|/>)", "i" );

	var result = url_match_1.exec( content );

	if( !result )
	{
		url_match_1 = new RegExp( "<object.+data=['\\\"]?([^'\\\"\\s]+)['\\\"\\s]?.+</object>", "i" ); // for justin.tv
		result = url_match_1.exec( content );
	}
	if( result )
	{
		extracted[ 0 ] = result[ 1 ];
		extracted[ 1 ] = 0;
		content = content.str_replace( "'", '"' );
		var url_match_2 = new RegExp( 'type="?application/x\\-shockwave\\-flash"?', "i" );
		result = url_match_2.exec( content );
		if( result )
		{
			var url_match_3 = new RegExp( 'width="(\\d+)"',  "ig" );
			var url_match_4 = new RegExp( 'height="(\\d+)"', "ig" );
			var result_w = url_match_3.exec( content );
			var result_h = url_match_4.exec( content );
			if( result_w && result_h )
			{
				var w = parseInt( result_w[ 1 ] );
				var h = parseInt( result_h[ 1 ] );
				if( '' + w == result_w[ 1 ] && '' + h == result_h[ 1 ] && w > 0 )
				{
					extracted[ 1 ] = w;
					extracted[ 2 ] = h;
				}
			}
			else
			{	// width, height present in element style?
				url_match_3 = new RegExp( 'style=.*width\\s*:\s*(\\d+)px',  "ig" );
				url_match_4 = new RegExp( 'style=.*height\\s*:\s*(\\d+)px', "ig" );
				result_w = url_match_3.exec( content );
				result_h = url_match_4.exec( content );
				if( result_w && result_h )
				{
					var w = parseInt( result_w[ 1 ] );
					var h = parseInt( result_h[ 1 ] );
					if( '' + w == result_w[ 1 ] && '' + h == result_h[ 1 ] && w > 0 )
					{
						extracted[ 1 ] = w;
						extracted[ 2 ] = h;
					}
				}
			}
			if( extracted[ 1 ] != 0 )
			{
				// ustream.tv has flashvars attribute in embed tag
				var url_match_5 = new RegExp( 'flashvars="([^\\\"]+)"', "i" );
				var result_fp = url_match_5.exec( content );
				if( result_fp )
				{
					extracted[ 3 ] = result_fp[ 1 ].str_replace( "'", "&apos;" );
				}
				else
				{
					// justin.tv has flashvars in params tag
					url_match_5 = new RegExp( 'name="flashvars" value="([^\\\"]+)"', "i" );
					result_fp = url_match_5.exec( content );
					if( result_fp )
					{
						extracted[ 3 ] = result_fp[ 1 ].str_replace( "'", "&apos;" );
					}
					else
					{
						extracted[ 3 ] = '';
					}
				}
				extracted[ 2 ] = parseInt( extracted[ 2 ] * new_width / extracted[ 1 ] );
				extracted[ 1 ] = new_width;
				return extracted;
			}
		}
	}

	return false;
}

String.prototype.isQuestion   = function( ) { return this.indexOf( '?' ) >= 0; }
 
var oniPaperReady = function( e ) { }

function scribd_clicked( link, ipaper_id, ipaper_access_key, attach_id )
{
	$( '#big_media_container' ).get( 0 ).innerHTML = '<div id="media_container"></div>';
	$( '.dynamicContent' ).show( );
	document.getElementById('study_file_id').value = attach_id;
	$('#comment_content #comment_file_comment').get(0).value = ''; 
	$('#comment_content .comment_container #file_comment_comment').get(0).innerHTML = ''; 
	$('#comment_list').get(0).innerHTML = ''; 
	if(attach_id !=0 && attach_id !='') 
		$('#comment_content').show();
	else
		$('#comment_content').hide();


	var scribd_doc = scribd.Document.getDoc( ipaper_id, ipaper_access_key );
	scribd_doc.addParam( 'jsapi_version', 1 );
	scribd_doc.addParam( 'height', 500 );
	scribd_doc.addParam( 'width', 530 );
	scribd_doc.addParam( 'wmode', 'transparent' );
	scribd_doc.addParam( 'allowfullscreen', 'false' );
	scribd_doc.addEventListener( 'iPaperReady', oniPaperReady );
	scribd_doc.write( "media_container" );
	remove_playing_now( );
	add_playing_now( link.parentNode, 2 );

	return false;
}
function image_clicked( link, href, title, attach_id )
{
	if( $.browser.msie ){
		var img = document.createElement( 'img' );
		document.getElementById('study_file_id').value = attach_id;
		$('#comment_content #comment_file_comment').get(0).value = ''; 
		$('#comment_content .comment_container #file_comment_comment').get(0).innerHTML = ''; 
		$('#comment_list').get(0).innerHTML = ''; 		
		if(attach_id !=0 && attach_id !='') 
			$('#comment_content').show();
		else
			$('#comment_content').hide();
		
		var random_id = 'tmp_img_' + Math.floor( Math.random( ) * 4294967295 );
		img.style.position = 'absolute';
		img.src = href;
		img.id = random_id;
		img.style.visibility = 'hidden';
		document.body.appendChild( img );
		var h = img.height;
		var w = img.width;
		$( '#' + random_id ).remove( );
		
		inline_open_image( h, w, link, href, title );
	} else {
		var img = new Image( );
		img.src = href;
		
		document.getElementById('study_file_id').value = attach_id;
		$('#comment_content #comment_file_comment').get(0).value = ''; 
		$('#comment_content .comment_container #file_comment_comment').get(0).innerHTML = ''; 
		$('#comment_list').get(0).innerHTML = ''; 		
		if(attach_id !=0 && attach_id !='') 
			$('#comment_content').show();
		else
			$('#comment_content').hide();


		$( img ).load( function( ){
			// need to remove these in of case img-element has set width and height
			$(this).removeAttr( "width" ).removeAttr( "height" );

			inline_open_image( this.height, this.width, link, href, title );
		} );
	}
	return false;
}

function inline_open_image( real_height, real_width, link, href, title )
{
	if( ( real_height > 500 || real_width > 530 ) && ( real_height * real_width > 0 ) )
	{
		$( '#big_media_container' ).get( 0 ).innerHTML = '<div id="media_container"></div>';
		$( '.dynamicContent' ).show( );
		remove_playing_now( );
		add_playing_now( link.parentNode, 2 );

		var new_h = Math.min( 500, real_height );
		var new_w = parseInt( '' + ( real_width * new_h / real_height ) );
		new_w = Math.min( 530, new_w );
		new_h = parseInt( '' + ( real_height * new_w / real_width ) );
		// $( '#big_media_container #media_container' ).get( 0 ).innerHTML = '<img src="' + href + '" title="' + title + '" alt="' + title + '" width="' + new_w + '" height="' + new_h + '" longdesc="' + href + '" />';
		// $( '#big_media_container #media_container img' ).fullsize( ); - does not work nice
		$( '#big_media_container #media_container' ).get( 0 ).innerHTML = '<a target="_blank" href="' + href + '" title="' + title + '"><img src="' + href + '" alt="' + title + '" width="' + new_w + '" height="' + new_h + '" /></a>';
	}
	else
	{
		$( '#big_media_container' ).get( 0 ).innerHTML = '<div id="media_container"></div>';
		$( '.dynamicContent' ).show( );
		$( '#big_media_container #media_container' ).get( 0 ).innerHTML = '<img src="' + href + '" title="' + title + '" />';
	}
	remove_playing_now( );
	add_playing_now( link.parentNode, 2 );
}

function remove_playing_now( )
{
	if( $( '#playing_now' ) )
	{
		$( '#playing_now' ).remove( );
	}
}
function add_playing_now( node, message_type )
{
	var message = '';
	if( message_type == 1 )
		message = '[playing now...]';
	else
		message = '[open now...]';
	node.innerHTML += '<span id="playing_now"> ' + message + ' </span>';
}
var flashParams = { "wmode": "transparent", "allowfullscreen": "false" };
function link_clicked( link )
{
	var href = link.href;
	var found = false;

	// YouTube
	var yt  = new RegExp( "youtube\\.", 'i' );
	var ytm = new RegExp( "(?:watch\\?v=)([\\w\\-]+)", 'i' );
	if( yt.test( href ) && ytm.test( href ) )
	{
		// alert( ytm.exec( href )[ 1 ] ); size available on youtube 480x295
		swfobject.embedSWF( "http://www.youtube.com/v/" + ytm.exec( href )[ 1 ], "media_container", "530", "326", "9.0.0", "expressInstall.swf", false, flashParams );
		found = true;
	}

	// Google video
	var gv  = new RegExp( "video\\.google\\.", 'i' );
	var gvm = new RegExp( "(?:videoplay\\?docid=)([\\w\\-]+)", 'i' );
	if( gv.test( href ) && gvm.test( href ) )
	{
		// alert( gvm.exec( href )[ 1 ] ); original size 400x326
		swfobject.embedSWF( "http://video.google.com/googleplayer.swf?docid=" + gvm.exec( href )[ 1 ], "media_container", "530", "432", "9.0.0", "expressInstall.swf", false, flashParams );
		found = true;
	}

	// vimeo
	var vm = new RegExp( "(?:vimeo.com/)(\\d+)", 'i' );
	if( vm.test( href ) )
	{
		// alert( vm.exec( href )[ 1 ] ); original size 400x225
		swfobject.embedSWF( "http://vimeo.com/moogaloop.swf?clip_id=" + vm.exec( href )[ 1 ] + "&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1", "media_container", "530", "305", "9.0.0", "expressInstall.swf", false, flashParams );
		found = true;
	}

	if( found )
	{
		$( '.dynamicContent' ).show( );
		remove_playing_now( );
		add_playing_now( link.parentNode, 1 );
		return false;
	}
	else
		return true;

}
function embedded_clicked( url, width, height, flashvars, attach_id, link )
{

	$( '.dynamicContent' ).show( );
	remove_playing_now( );	
	document.getElementById('study_file_id').value = attach_id;
	$('#comment_content #comment_file_comment').get(0).value = ''; 
	$('#comment_content .comment_container #file_comment_comment').get(0).innerHTML = ''; 
	if(attach_id !=0 && attach_id !='' && attach_id != null) 
		$('#comment_content').show();
	else
		$('#comment_content').hide();
		
	$('#comment_list').get(0).innerHTML = ''; 
	
	$( '#big_media_container' ).get( 0 ).innerHTML = '<div id="media_container"></div>';

	if( flashvars != '' ){ jQuery.extend( flashParams, { 'flashvars': flashvars } ); }
	swfobject.embedSWF( url, "media_container", width, height, "9.0.0", "expressInstall.swf", false, flashParams );
	add_playing_now( link.parentNode, 1 );
	return false;
}

function newMessage( user, messageType, message, nick, id_color ) {


split_id = id_color.split('#');
attach_id = split_id[0]
	

actual_chat_detail=split_id[1].split("$$")

actual_chat_time_now=actual_chat_detail[1];



actual_time=new Date(actual_chat_time_now);
now_time=new Date();


total_diff_in_time=now_time-actual_time;
var secs=total_diff_in_time/1000;
if(secs<=1000)
{
val=document.getElementById('sound_notification').value;
if(val=="true")
{
play_sound();
}
}
var mins=secs/60;
var hours=mins/60;
while(mins>=60)
{
mins=mins-60;
}
while(secs>=60)
{
secs=secs-60;
}
hours=parseInt(hours);
mins=parseInt(mins);
secs=parseInt(secs);




  var _path = default_image;
  var _logo_class = '';
  if( typeof( images_path[ user ] ) == "undefined" ) {
    _logo_class = 'class="logo_for_' + user + '"';
    // if missing_images[ user ] then it means we already did a request to find its image path
    if( typeof( missing_images[ user ] ) == "undefined" ) {
      missing_images[ user ] = 1;
      jQuery.ajax( {
        type: "GET",
        url: get_user_image_url,
        data: "id=" + user,
        user: user,
        default_image: _path,
        success: function( msg, user ){
          if( msg != '' ) {
            jQuery( '.logo_for_' + this.user ).attr( "src", msg );
            images_path[ this.user ] = msg;
          } else {
            images_path[ this.user ] = this.default_image;
          }
        }
      } );
    }
  }
  else { _path = images_path[ user ]; }
  var shown_nick = nick;

  if( user == AristoChat.xpmm_user )
    shown_nick =  shown_nick ;

  // do we have to scroll after we add next message? (2px is a margin we take into acccount, scroll bar doesnt have to be exactly at the bottom)
  var will_scroll = ( user == AristoChat.xpmm_user ) || ( jQuery( '#chatContent' ).height( ) + jQuery( '#chatContent' ).get( 0 ).scrollTop + 2 >= jQuery( '#chatContent' ).get( 0 ).scrollHeight );

var message_list = message.split("##")

		var image= "";
		var thumb="";
	if (!previous_user)
	{
		 jQuery( '#chatContent' ).prepend('<div id="log-arrow" ></div>');
		}

		img_url = "";
if(previous_user==user)
{	
	first ='<div class="chatMessage"><div class="chat-row a3 ' + user +' " style="background-color:#'+actual_chat_detail[0]+'"  id="id_'+attach_id+ '" ><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt">'
		
	fi_l = '</div><div class="timestamp">'
  last = '<div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>'	
		if(hours==0 && mins==0)
			mid = ' few seconds ago</div>'
		else if(hours==0)
			mid = mins + ' minutes ago</div>'
		else
			mid =  hours + ' hours ago</div>'	
	 				
		document.getElementById("id_"+old_id).setAttribute("class", "chat-row a" + user +"  same-author");
		 
		 jQuery( '#chatContent' ).prepend(first+message+fi_l+mid+last)	
	
}
else
{
	first ='<div class="chatMessage"><div class="chat-row a3 ' + user +' "  style="background-color:#'+actual_chat_detail[0]+'"  id="id_'+attach_id+ '" ><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt">'
	fi_l ='</div><div class="timestamp">'
	last ='<div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>'
if(hours==0 && mins==0)
  mid=  ' few seconds ago</div>' ;
else if(hours==0)
  mid=  mins +' minutes ago</div>';
else
  mid=  hours +' hours ago</div>' ;
			
		 jQuery( '#chatContent' ).prepend(first+message+fi_l+mid+last)	

}


/*

if(is_image[0]!="file_uploaded")
{
if(previous_user==user)
{
if(hours==0 && mins==0)
{
  $( '#chatContent' ).prepend( '<div class="chatMessage"><div class="chat-row a' + user +' same-author" style="margin-top:-3px;margin-bottom:-6px;"><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt"><p>' + message + '</p></div><div class="timestamp">' +  secs +' seconds ago</div><div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>' );
}
else if(hours==0)
{
  $( '#chatContent' ).prepend( '<div class="chatMessage"><div class="chat-row a' + user +' same-author" style="margin-top:-3px;margin-bottom:-6px;"><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt"><p>' + message + '</p></div><div class="timestamp">' + mins + ' minutes ago</div><div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>' );
}
else
{
  $( '#chatContent' ).prepend( '<div class="chatMessage"><div class="chat-row a' + user +' same-author" style="margin-top:-3px;margin-bottom:-6px;"><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt"><p>' + message + '</p></div><div class="timestamp">' + hours + ' hours ago</div><div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>' );

}
}
else
{
if(hours==0 && mins==0)
{
  $( '#chatContent' ).prepend( '<div class="chatMessage"><div class="chat-row a' + user +'" style="margin-bottom:13px;"><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt"><p>' + message + '</p></div><div class="timestamp">'+  secs +' seconds ago</div><div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>' );
}
else if(hours==0)
{

  $( '#chatContent' ).prepend( '<div class="chatMessage"><div class="chat-row a' + user +'" style="margin-bottom:13px;"><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt"><p>' + message + '</p></div><div class="timestamp">'+  mins +' minutes ago</div><div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>' );
}
else
{

  $( '#chatContent' ).prepend( '<div class="chatMessage"><div class="chat-row a' + user +'" style="margin-bottom:13px;"><div class="box-top"></div><div class="box-top-right"></div><span class="author">' + shown_nick + '</span><div class="chat-log-msg alt"><p>' + message + '</p></div><div class="timestamp">'+  hours +' hours ago</div><div class="box-bottom-right"></div><div class="box-bottom"></div></div></div>' );
}
}
}
*/


  

if( will_scroll )
    jQuery( '#chatContent' ).get( 0 ).scrollTop = jQuery( '#chatContent' ).get( 0 ).scrollHeight;
previous_user=user
old_id = attach_id

clear_data();
}
function newUser( user, fullname, vertical, image_mark ) {
  var image_mark_class = '';
  if( image_mark == '1' ) image_mark_class = 'class="wc-user"';
  var _path = default_image;
  if( typeof( images_path[ user ] ) != "undefined" ) _path = images_path[ user ];
  var asterix = '';
  if( user == AristoChat.xpmm_user )
    asterix = '<em>*</em>';
  jQuery( '#usersBar' ).append( '<div class="userInfo" id="' + user + '"><ul class="online-users"><li class="online"><a href="/chat">' + fullname +' </a></li></ul></div>' );

}

function toggleMedia( ) {
  var visible = true;
  if( $('.dynamicContent' ).css( 'display') == 'none' ) visible = false;
  if( visible ) {
    $( '.dynamicContent' ).hide( );
    $( '#big_media_container' ).get( 0 ).innerHTML = '<div id="media_container">No media content yet</div>';
    remove_playing_now( );
  } else {
    $( '.dynamicContent' ).show( );
  }
  return false;
}

AristoChat = {
	connection: null,
	inputField: "userMessage",
	fileField: "my_file_element",
	onEnterNewMessageBefore: function(msg) { return msg },
	onEnterNewMessageAfter: function(msg) { },
	ADMIN: "Admin",
	// isAdmin: function(from) { return from.toLowerCase( ).endsWith( '/' + AristoChat.ADMIN.toLowerCase( ) ) }
	isAdmin: function( from ) { return from.toLowerCase( ) == AristoChat.ADMIN.toLowerCase( ) },
	messageType: { file: 0, question: 1, text: 2, link: 3 },
	messageIcons: function( type ){ var paths = Array( ); paths[ AristoChat.messageType.file ] = '/images/chat/file-icon.png'; paths[ AristoChat.messageType.question ] = '/images/chat/question-icon.png'; paths[ AristoChat.messageType.text ] = '/images/chat/message-icon.png'; paths[ AristoChat.messageType.link ] = '/images/chat/Link_Icon.jpg'; return paths[ type ]; },
	messageDescriptions: function( type ){ var paths = Array( ); paths[ AristoChat.messageType.file ] = 'new file uploaded'; paths[ AristoChat.messageType.question ] = 'new question asked'; paths[ AristoChat.messageType.text ] = 'new message'; paths[ AristoChat.messageType.link ] = 'new link'; return paths[ type ]; }
}

var connection = AristoChat.connection;

function log(       msg  ) { if( DEBUG ) $( '#chatContent' ).append( '<div></div>' ).append( document.createTextNode( msg ) ); }
function rawInput(  data ) { log( 'RECV: ' + data ); }
function rawOutput( data ) { log( 'SENT: ' + data ); }



function onMessage(msg) {


	var from = msg.getAttribute('from');
	var type = msg.getAttribute('type');
	var body = msg.getElementsByTagName("body")[0].childNodes[0];
	var id_ele = msg.getAttribute('id');

	var message_type = null;
	if( msg.getElementsByTagName("message_type")[0] ) {
		message_type = msg.getElementsByTagName("message_type")[0].childNodes[0].nodeValue;

	}
	
	var user = Strophe.getResourceFromJid( from );

	if( !user ) { return true; }
	
	var nick = '';
	if( msg.getElementsByTagName("nick")[0] ) 	{
		nick = msg.getElementsByTagName("nick")[0].childNodes[0].nodeValue;
	} else {
		nick = user;
	}

	if (type == "groupchat" && body) {

		// body = body.nodeValue.replace(/(<([^>]+)>)/ig,"");


// here where i get the message



		body = body.nodeValue;


		if( message_type == 'file_uploaded' || message_type == 'image_uploaded' ) {

		/*	var href = msg.getElementsByTagName("file_path")[0].childNodes[0].nodeValue;
			var uploaded_by = msg.getElementsByTagName("uploaded_by")[0].childNodes[0].nodeValue;			
			if(msg.getElementsByTagName("attach_id")[0])
				var attach_id = msg.getElementsByTagName("attach_id")[0].childNodes[0].nodeValue;
			else
				var attach_id = 0;
			var uploaded_by_xpmm_user = msg.getElementsByTagName("uploaded_by_xpmm_user")[0].childNodes[0].nodeValue;
			if( message_type == 'image_uploaded' ) {

				// it's an announcement about a new image file
				var img_title = msg.getElementsByTagName("file_title")[0].childNodes[0].nodeValue.escapeHTML( );
				newMessage( uploaded_by_xpmm_user, AristoChat.messageType.file, "<a target='_blank' href='#' onclick='return image_clicked( this, \"" + href + "\", \"" + img_title + "\", \"" + attach_id + "\")'>" + body.escapeHTML( ) + "</a> <a target='_blank' href='" + href + "'>[download]</a>", uploaded_by, attach_id );
			} else {


				// it's an announcement about a new uploaded file
				newMessage( uploaded_by_xpmm_user, AristoChat.messageType.file, "<a target='_blank' href='" + href + "'>" + body.escapeHTML( ) + "</a>", uploaded_by, attach_id );
			}*/
		} else if( message_type == 'scribd_file' ) {
			// it's an announcement about a new uploaded file to scribd
			/*var ipaper_id = msg.getElementsByTagName("ipaper_id")[0].childNodes[0].nodeValue;
			var ipaper_access_key = msg.getElementsByTagName("ipaper_access_key")[0].childNodes[0].nodeValue;
			var uploaded_by = msg.getElementsByTagName("uploaded_by")[0].childNodes[0].nodeValue;
			if(msg.getElementsByTagName("attach_id")[0])
				var attach_id = msg.getElementsByTagName("attach_id")[0].childNodes[0].nodeValue;
			else
				var attach_id = 0;
			var uploaded_by_xpmm_user = msg.getElementsByTagName("uploaded_by_xpmm_user")[0].childNodes[0].nodeValue;
			var text = "<a href='#' onclick='return scribd_clicked( this, " + ipaper_id + ", \"" + ipaper_access_key + "\", " + attach_id + " );'>" + body.escapeHTML( ) + "</a>";
			try {
				// older messages with scribd_file saved in xmpp server, dont have file_path tag
				var href = msg.getElementsByTagName("file_path")[0].childNodes[0].nodeValue;
				text += ' <a target="_blank" href="' + href + '">[download]</a>'

			} catch ( error ){ }

			newMessage( uploaded_by_xpmm_user, AristoChat.messageType.file, text, uploaded_by, attach_id );*/
		} else {


			var messageType = AristoChat.messageType.text;

			var embedded = body.extractEmbedded( );

			var attach_id = 0;

			if(msg.getAttribute("attach_id"))
				attach_id = msg.getAttribute("attach_id");	

			if( embedded )
			{

				messageType = AristoChat.messageType.file;				
				body = '<a href="#" onclick="return embedded_clicked( \'' + embedded[ 0 ] + '\', ' + embedded[ 1 ] + ', ' + embedded[ 2 ] + ', \'' + embedded[ 3 ] + '\',' + attach_id + ', this );">new media file</a>';

			}
			else
			{

				var link = body.extractLink( );

				if( link )

				{


					messageType = AristoChat.messageType.link; // contains a link

		//			body = body.str_replace( link, '<a target="_blank" href="' + link.to_href( ) + '" onclick="return link_clicked( this );">' + link + '</a>' );

				}
				else
				{


					if( body.isQuestion( ) )
						messageType = AristoChat.messageType.question; // it's a question

				}
			}


			newMessage( user, messageType, body, nick, id_ele );
		}
		// $('html, body').animate({scrollTop: $('.message:last').offset().top }, 5);
	}
	// we must return true to keep the handler alive.  
	// returning false would remove it after it finishes.
	return true;
}

function user_connected( fullname, userId, vertical, image_mark ) {

  jQuery('#' + userId).hide("slow").remove();
  newUser( userId, fullname, vertical, image_mark );
  // $('#chat').append("<tr class='presence'><td class='nick'>"+ nick + "</td><td class='body'>has entered the room</td></tr>");
  // $('html, body').animate({scrollTop: $('.message:last').offset().top }, 5);
}

function user_disconnected( nick, userId ) {

  jQuery( '#' + userId ).hide( "slow" ).remove();
  if( userId == AristoChat.xpmm_user )
  {
    // if the user disconnected is current user, show an offline message
    jQuery( '#messageBox ul li.invite'  ).hide( );
    jQuery( '#messageBox ul li.message' ).hide( );
    jQuery( '#messageBox ul li.offline' ).show( );
  }
  // $('#chat').append("<tr class='presence'><td class='nick'>"+ nick + "</td><td class='body'>has left the room</td></tr>");
  // $('html, body').animate({scrollTop: $('.message:last').offset().top }, 5);    
}

function onPresence(msg) {

  var user = Strophe.getResourceFromJid(msg.getAttribute('from'));
  var type = msg.getAttribute('type');

  var _vertical = 'Participant';
  var _path = default_image;
  var _image_mark = '';
  var _fullname = '';


  if( msg.getElementsByTagName("nick")[0] ) {
    _fullname = msg.getElementsByTagName("fullname")[0].childNodes[0].nodeValue;
  }
  if( msg.getElementsByTagName("vertical")[0] ) {
    _vertical = msg.getElementsByTagName("vertical")[0].childNodes[0].nodeValue;
  }
  if( msg.getElementsByTagName("image_path")[0] ) {
    _path = msg.getElementsByTagName("image_path")[0].childNodes[0].nodeValue;
  }
  if( msg.getElementsByTagName("image_mark")[0] ) {
    _image_mark = msg.getElementsByTagName("image_mark")[0].childNodes[0].nodeValue;
  }

  images_path[ user ] = _path;

  // don't show admin entered/left the room
  // if( !AristoChat.isAdmin( msg.getAttribute('from') ) ) {
  if( !AristoChat.isAdmin( user ) )
  {
    if (type == "unavailable") {
      user_disconnected( _fullname, user );
    } else if (type == "error") {
     // onDisconnect();
      if( msg.getElementsByTagName("text")[ 0 ] )
      	alert(msg.getElementsByTagName("text")[0].childNodes[0].nodeValue);
      else
			  //user_connected( _fullname, user, _vertical, _image_mark );
      	alert('Please try again. Campus reached maximum user limit.');
    } else {
      user_connected( _fullname, user, _vertical, _image_mark );
    }

  }

  // we must return true to keep the handler alive.  
  // returning false would remove it after it finishes.
  return true;
}

function onConnect(status) {

    if (status == Strophe.Status.CONNECTING) {
        jQuery('#loader').show();
        log('Strophe is connecting.');
        jQuery('#status').text('Connecting...');
    } else if (status == Strophe.Status.DISCONNECTING) {
        jQuery('#loader').show();
        jQuery('#status').text('Disconnecting...');
        log('Strophe is disconnecting.');
    } else if (status == Strophe.Status.AUTHENTICATING) {
        jQuery('#loader').show();
        jQuery('#status').text('Authenticating...');
        log('Strophe is authenticating.');
    } else if (status == Strophe.Status.CONNFAIL) {
        log('Strophe failed to connect.');
        jQuery('#status').text('Connection failed');
       // onDisconnect();
        jQuery('#loader').hide();
    } else if (status == Strophe.Status.DISCONNECTED) {
        log('Strophe is disconnected.');
        jQuery('#status').text('Disconnected');
     //   onDisconnect();
        jQuery('#loader').hide();
    } else if (status == Strophe.Status.AUTHFAIL) {
        jQuery('#status').text('Authentication failed');
        alert("Authentication failed, please retry.");
      //  onDisconnect();
        jQuery('#loader').hide();
    } else if (status == Strophe.Status.CONNECTED) {
        // Handlers
       connection.addHandler(onMessage,    null, 'message',        null,    null,  null); 
        connection.addHandler(onPresence,   null, 'presence',       null,    null,  null); 
        connected();
        log('Strophe is connected.');
        // Entrering the room
        // connection.send($pres({to: MUC_ROOM + "@" + MUC_COMPONENT + "/" + AristoChat.nick_userId( )}).c("x", {xmlns: "http://jabber.org/protocol/muc"}).tree());





        connection.send($pres({to: MUC_ROOM + "@" + MUC_COMPONENT + "/" + AristoChat.xpmm_user}).c("x", {xmlns: "http://jabber.org/protocol/muc"}).up().c("nick", {xmlns: "http://jabber.org/protocol/nick"}).t(AristoChat.nick).up().c("vertical", {}).t(AristoChat.vertical).up().c("image_path", {}).t(AristoChat.image_path).up().c("image_mark", {}).t(AristoChat.image_mark).up().c("fullname", {}).t(AristoChat.fullname).tree());

        // $('#loader').hide();
        //$('.page_init').empty(); // empty(), not hide(), because of scribd fullscreen, then exit fullscreen, make page_init div visible
    }
}

function connected() {

return false;
    if( !autologin )
    {
      user_connected( AristoChat.nick, AristoChat.xpmm_user, AristoChat.vertical, '0' );
    }
    jQuery('#status').text( 'Connected as ' + AristoChat.nick );
    jQuery('#connect').get(0).value = 'Disconnect';
    jQuery('#login').hide();
    jQuery('#roster').show()
    jQuery('#connect').removeAttr("disabled"); // To enable
    jQuery('#post').removeAttr("disabled"); // To enable
}

function onDisconnect() {

    if(AristoChat.nick != "")
      user_disconnected( AristoChat.nick, AristoChat.xpmm_user );
connection.reset( );
return false;   
    jQuery('#post').attr("disabled", "disabled"); // To disable
    jQuery('#connect').get(0).value = 'Connect';
    jQuery('#login').show();
    jQuery('#roster').hide()
    jQuery('#connect').removeAttr("disabled"); // To enable

    // 2009-08-26
    jQuery('#connect').get(0).value = 'Disconnected';
    jQuery('#connect').attr("disabled", "disabled"); // To disable
    jQuery('#image_form_uploaded_data').attr("disabled", "disabled"); // To disable

}


function setHeightForContainer( ) {
  var h = jQuery('#chat').height( ) - jQuery('.wccheader-chat').height( ) - jQuery('#messageBox').height( ) - jQuery('#footerChat').height( ) - 3;
  if( h ) { h = Math.max( h, 500 );  } else { h = 500; }
  h="auto"
  jQuery('#usersBar').height( h ); jQuery('#chatContent').height( h ); jQuery('.openContent').height( h ); jQuery('.borderContent').height( h ); 
  jQuery('.dynamicContent').height( h );
}

jQuery(document).ready(function () { 

    var last = new Date();
    var items = 0;
    var max_items = 5;
  connection = new Strophe.Connection(BOSH_SERVICE);
    if( autologin )
    {
      AristoChat.nick       = nick;
      AristoChat.vertical   = vertical;
      AristoChat.image_path = image_path;
      AristoChat.image_mark = image_mark;
      AristoChat.xpmm_user  = xpmm_user;
      AristoChat.fullname   = fullname;
      connection.attach( bosh_jid, bosh_sid, bosh_rid, onConnect );
    }
    else
    {
    }

    connection.rawInput  = rawInput;
    connection.rawOutput = rawOutput;

     jQuery('#post').bind('click', store_message_js);
    jQuery( "#userMessage" ).bind( "keyup", function( e ){ if (e.keyCode == 13) { store_message_js( ); return false; } } );


/*
    $('#connect').bind('click', function () {
        var button = $('#connect').get(0);
        if (button.value == 'Connect') {
            $('#connect').attr("disabled", "disabled"); // To disable 
            $('#loader').show();
            if($('#nick').get(0).value == "") {
              AristoChat.nick      = Strophe.getNodeFromJid($('#jid').get(0).value);
              AristoChat.xpmm_user = Strophe.getNodeFromJid($('#jid').get(0).value);
            }
            else {
              AristoChat.nick = $('#nick').get(0).value;
            }
            AristoChat.jid = $('#jid').get(0).value;
            AristoChat.password = $('#pass').get(0).value;
            connection.connect(AristoChat.jid, AristoChat.password, onConnect);
        } else {
            $('#connect').attr("disabled", "disabled"); // To disable 
            $('#loader').show();
            connection.disconnect();
        }
    });
*/

    setHeightForContainer( );
});

// THis function need to be called when you submit the chat message  - selva
function sendMessageWithCallbacksFromInputField( ){

	// var msg = $('#'+AristoChat.inputField).get(0).value.replace(/(<([^>]+)>)/ig,"");
	var msg = jQuery('#'+AristoChat.inputField).get(0).value.escapeHTML( );
//var d=new Date();
//msg=msg+d.toUTCString()
	//sendMessageWithCallbacks( msg, 0 );
	jQuery('#'+AristoChat.inputField).get(0).value = "";
var file = jQuery('#'+AristoChat.fileField).get(0).value.escapeHTML( );

if(!file.length)
{
var type="Just_message"
}
else
{
var type="File_uploaded"
}
	sendMessageWithCallbacks( msg,type, 0 );


}

function sendMessageWithCallbacks( msg, type, fileobj ){
var d=new Date();
d=d.toUTCString()
content_type=type;

	msg = AristoChat.onEnterNewMessageBefore( msg );
	connection.send($msg( { to: MUC_ROOM + "@" + MUC_COMPONENT, type: "groupchat", id: connection.getUniqueId, attach_id: d, messageType: content_type } ).c( "body" ).t( msg ).up().c( "nick", {xmlns: "http://jabber.org/protocol/nick" } ).t( AristoChat.nick ).tree( ) );
	AristoChat.onEnterNewMessageAfter( msg );
}

function sendMessageWithCallbacksFromEmbedded( ){

	$('#facebox .embed_video .upload_loading').show( );
	$('#facebox .embed_video .upload_message').get(0).innerHTML = '';
	$('#facebox .embed_video .ok_upload_message').get(0).innerHTML = '';
	$('#facebox .embed_video .errorsec').hide( );
	$('#facebox .embed_video .ok_message').hide( );

	var msg = $( '#facebox .embedded_code' ).get( 0 ).value;
	var link = msg.extractLink( );
	if( link )
	{
		embedmsg = msg.split( '&amp;' ).join( 'ooo' );
		embedmsg = embedmsg.split( '&' ).join( '--' );
		
		$.ajax({ type: "POST",
      url: document.getElementById('uploadContent').action,
      data: "embedcontent=" + embedmsg,
			success: function( obj ){			
				sendMessageWithCallbacks( msg.escapeHTML( ), obj );
      }
    });		
		
		$( '#facebox .embedded_code' ).get( 0 ).value = "";
		$('#facebox .embed_video .ok_message').show( );
		$('#facebox .embed_video .ok_upload_message').get( 0 ).innerHTML = 'Embedded file sent to chat users.';
	}
	else
	{
		$('#facebox .embed_video .errorsec').show( );
		$('#facebox .embed_video .upload_message').get(0).innerHTML = 'We could not embed the file';
	}
	$('#facebox .embed_video .upload_loading').hide( );
}
