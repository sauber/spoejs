<script language="javascript" type="text/javascript">
var agt = navigator.userAgent.toLowerCase();
var is_major  = parseInt( navigator.appVersion );
var is_minor  = parseFloat(  navigator.appVersion );
var is_nav    = (( agt.indexOf( 'mozilla' ) != -1 ) && 
	         ( agt.indexOf( 'spoofer' ) == -1 ) &&
                 ( agt.indexOf( 'compatible' ) == -1 ) &&
                 ( agt.indexOf( 'opera' ) == -1 ) &&
                 ( agt.indexOf( 'webtv' ) == -1 ) );
var is_nav4up = ( is_nav && ( is_major >= 4 ) );
var is_ie     = ( agt.indexOf( 'msie' ) != -1 );
var is_ie4up  = ( is_ie && ( is_major >= 4 ));

var obj_ref, style_ref;
if ( is_nav4up == true ) {
  obj_ref   = "";
  style_ref = "";
}
if ( is_ie4up == true ) {
  obj_ref   = ".all";
  style_ref = ".style";
}
</script>