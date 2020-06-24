<?php 
session_start();

require_once("vendor/autoload.php");

use \Slim\Slim;
use \Hcode\Page;
use \Hcode\PageAdmin;
use \Hcode\Model\User;
use \Hcode\Model\Category;

$app = new Slim();

$app->config('debug', true);

$app->get('/', function() {
	
	$page = new Page(); //chama o metodo __construct e adiciona o "header" na tela

	$page->setTpl("index"); //carrega o conteudo da pagina
						//limpa a memoria, chama o metodo __destruct e adiciona o "footer" na tela
});

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

	$_POST['despassword'] = password_hash($_POST["despassword"], PASSWORD_DEFAULT, [

		"cost"=>12

	]);

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

$app->get("/admin/categories", function() { //exibe a lista de categorias de produtos disponiveis

	User::verifyLogin();

	$categories = Category::listAll();

	$page = new PageAdmin();

	$page->setTpl("categories", [
		'categories'=>$categories
	]);

});

$app->get("/admin/categories/create", function() { //exibe a pagina de criacao de uma categoria

	User::verifyLogin();

	$page = new PageAdmin();

	$page->setTpl("categories-create");

});

$app->post("/admin/categories/create", function() { //cria uma nova categoria

	$category = new Category();

	$category->setData($_POST);

	$category->save();

	header('Location: /admin/categories');
	exit;

});

$app->get("/admin/categories/:idcategory/delete", function($idcategory) { //exclui uma categoria

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$category->delete();

	header('Location: /admin/categories');
	exit;

});

$app->get("/admin/categories/:idcategory", function($idcategory) {

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$page = new PageAdmin();

	$page->setTpl("categories-update", [
		'category'=>$category->getValues()
	]);

});

$app->post("/admin/categories/:idcategory", function($idcategory) {

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$category->setData($_POST);

	$category->save();

	header('Location: /admin/categories');
	exit;

});

$app->run();

?>