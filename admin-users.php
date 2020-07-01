<?php

use \Hcode\PageAdmin;
use \Hcode\Model\User;

$app->get("/admin/users", function() { //exibe a pagina do usuario
	
	User::verifyLogin();
	
	$users = User::listAll();
	
	$page = new PageAdmin();
	
	$page->setTpl("users", array(
		"users"=>$users
	));
	
});
	
$app->get("/admin/users/create", function() { //exibe a pagina que cria o login do usuario
	
	User::verifyLogin();
	
	$page = new PageAdmin();
	
	$page->setTpl("users-create");
	
});

$app->get("/admin/users/:iduser/delete", function($iduser) { //recebe dados e deleta um usuario. precisa vir antes
															 //do users-update para ser executado normalmente
	User::verifyLogin();
	
	$user = new User();

	$user->get((int)$iduser);

	$user->delete();

	header("Location: /admin/users");
	exit;

});
	
$app->get("/admin/users/:iduser", function($iduser) { //exibe os dados do usuario solicitado
	
	User::verifyLogin();

	$user = new User();

	$user->get((int)$iduser);
	
	$page = new PageAdmin();
	
	$page->setTpl("users-update", array(
		"user"=>$user->getValues()
	));
	
});
	
$app->post("/admin/users/create", function() { //recebe dados e cria o login

	User::verifyLogin();

	$user = new User();

	$_POST["inadmin"] = (isset($_POST["inadmin"])) ? 1 : 0;

	$user->setData($_POST);

	$user->save();

	header("Location: /admin/users");
	exit;

});
	
$app->post("/admin/users/:iduser", function($iduser) { //recebe dados e altera dados do usuario

	User::verifyLogin();

	$user = new User();

	$_POST["inadmin"] = (isset($_POST["inadmin"])) ? 1 : 0;

	$user->get((int)$iduser);

	$user->setData($_POST);

	$user->update();

	header("Location: /admin/users");
	exit;

});

?>