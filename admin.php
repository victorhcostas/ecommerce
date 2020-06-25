<?php

use \Hcode\PageAdmin;
use \Hcode\Model\User;
use \Hcode\Mailer;

$app->get('/admin', function() {

	User::verifyLogin();
	
	$page = new PageAdmin(); //chama o metodo __construct e adiciona o "header" do admin na tela

	$page->setTpl("index"); //carrega o conteudo da pagina
	//limpa a memoria, chama o metodo __destruct e adiciona o "footer" do admin na tela
});

$app->get('/admin/login', function() { //pagina de login
	
	$page = new PageAdmin([
		"header"=>false,
		"footer"=>false
		]);
		
		$page->setTpl("login");
});
	
$app->post('/admin/login', function() { //exibe a pagina do admin se ele for autenticado
		
	User::login($_POST["login"], $_POST["password"]);
		
	header("Location: /admin");
		
	exit;
		
});
	
$app->get('/admin/logout', function() { //logout do usuario
	
	User::logout();
	
	header("Location: /admin/login");
	exit;
	
});

$app->get("/admin/forgot", function() { //Rota que renderiza a pagina que recupera a senha do usuario

	$page = new PageAdmin([
		"header" =>false,
		"footer"=>false
	]);

	$page->setTpl("forgot");

});

$app->post("/admin/forgot", function() { //Rota que faz a recuperacao da senha do usuario

	$user = User::getForgot($_POST["email"]);
	
	header("Location: /admin/forgot/sent");
	exit;

});

$app->get("/admin/forgot/sent", function() { //Rota que exibe a confirmacao do envio do email de recuperacao de email

	$page = new PageAdmin([
		"header"=>false,
		"footer"=>false
	]);

	$page->setTpl("forgot-sent");

});

$app->get("/admin/forgot/reset", function() { //Rota que exibe o campo de restauracao da senha

	$user = User::validForgotDecrypt($_GET["code"]);
	//var_dump($user);

	$page = new PageAdmin ([
		"header"=>false,
		"footer"=>false
		]);

	$page->setTpl("forgot-reset", array(
		"name"=>$user["desperson"],
		"code"=>$_GET["code"]
	));

});

$app->post("/admin/forgot/reset", function() { //Restaura a senha do usuario mantendo um hash no banco de dados

	$forgot = User::validForgotDecrypt($_POST["code"]);

	User::setForgotUsed($forgot["idrecovery"]);

	$user = new User();

	$user->get((int)$forgot["iduser"]);

	$password = password_hash($_POST["password"], PASSWORD_DEFAULT, [
		"cost"=>12
	]);

	$user->setPassword($password);

	$page = new PageAdmin ([
		"header"=>false,
		"footer"=>false
	]);

	$page->setTpl("forgot-reset-success");

});

?>