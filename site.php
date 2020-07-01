<?php

use \Hcode\Page;
use \Hcode\Model\Product;
use \Hcode\Model\Category;
use \Hcode\Model\Cart;
use \Hcode\Model\User;
use \Hcode\Model\Address;
use \Hcode\Mailer;

$app->get('/', function() {

	$products = Product::listAll();
	
	$page = new Page(); //chama o metodo __construct e adiciona o "header" na tela

	$page->setTpl("index", [//carrega o conteudo da pagina, limpa a memoria, chama o metodo __destruct e adiciona o "footer" na tela
		'products'=>Product::checkList($products)
	]); 
						
});

$app->get("/categories/:idcategory", function($idcategory) { //Exibe a pagina de produtos de uma categoria especifica
	
	$page = (isset($_GET['page'])) ? (int)$_GET['page'] : 1;

	$category = new Category();

	$category->get((int)$idcategory);

	$pagination = $category->getProductsPage($page);

	$pages = [];

	for ($i=1; $i <= $pagination['pages']; $i++) { //Conta e separa os produtos em paginas
		array_push($pages, [
			'link'=>'/categories/' . $category->getidcategory() . '?page=' . $i,
			'page'=>$i
		]);
	}

	$page = new Page();

	$page->setTpl("category", [
		'category'=>$category->getValues(),
		'products'=>$pagination["data"],
		'pages'=>$pages
	]);

});

$app->get("/products/:desurl", function($desurl) { //Exibe a pagina do produto

	$product = new Product();

	$product->getFromURL($desurl);

	$page = new Page();

	$page->setTpl("product-detail", [
		'product'=>$product->getValues(),
		'categories'=>$product->getCategories()
	]);

});

$app->get("/cart", function() { //Exibe a pagina do carrinho de compras

	$cart = Cart::getFromSession();

	$page = new Page();

	$page->setTpl("cart", [
		'cart'=>$cart->getValues(),
		'products'=>$cart->getProducts(),
		'error'=>Cart::getMsgError()
	]);

});

$app->get("/cart/:idproduct/add", function($idproduct) { //Adiciona um produto ao carrinho de compras

	$product = new Product();

	$product->get((int)$idproduct);

	$cart = Cart::getFromSession();

	$qtd = (isset($_GET['qtd'])) ? (int)$_GET['qtd'] : 1;

	for ($i = 0; $i < $qtd; $i++) {

		$cart->addProduct($product);

	}

	header("Location: /cart");
	exit;

});

$app->get("/cart/:idproduct/minus", function($idproduct) { //Remove 1 unidade de um produto do carrinho de compras

	$product = new Product();

	$product->get((int)$idproduct);

	$cart = Cart::getFromSession();

	$cart->removeProduct($product);

	header("Location: /cart");
	exit;

});

$app->get("/cart/:idproduct/remove", function($idproduct) { //Remove todos as unidades de um certo produto no carrinho

	$product = new Product();

	$product->get((int)$idproduct);

	$cart = Cart::getFromSession();

	$cart->removeProduct($product, true);

	header("Location: /cart");
	exit;

});

$app->post("/cart/freight", function() { //Calcula o frete na pagina do carrinho

	$cart = Cart::getFromSession();

	$cart->setFreight($_POST['zipcode']);

	header("Location: /cart");
	exit;

});

$app->get("/checkout", function() { //Exibe a pagina do checkout do pedido

	User::verifyLogin(false);

	$cart = Cart::getFromSession();

	$address = new Address();

	$page = new Page();

	$page->setTpl("checkout", [
		'cart'=>$cart->getValues(),
		'address'=>$address->getValues()
	]);

});

$app->get("/login", function() { //Exibe a pagina de login do cliente

	$page = new Page();

	$page->setTpl("login", [
		'error'=>User::getError(),
		'errorRegister'=>User::getErrorRegister(),
		'registerValues'=>(isset($_SESSION['registerValues'])) ? $_SESSION['registerValues'] : [
			'name'=>'', 'email'=>'', 'phone'=>'']
	]);

});

$app->post("/login", function() { //Realiza o login do cliente

	try {

		User::login($_POST['login'], $_POST['password']);

	} catch(Exception $e) {

		User::setError($e->getMessage());

	}

	header("Location: /checkout");
	exit;

});

$app->get("/logout", function() { //Realiza o logout do cliente

	User::logout();

	header("Location: /login");
	exit;

});

$app->post("/register", function() {

	$_SESSION['registerValues'] = $_POST;

	//Emite uma mensagem de erro se o nome nao for preenchido
	if (!isset($_POST['name']) || $_POST['name'] == '') {

		User::setErrorRegister("Preencha o seu nome.");
		header("Location: /login");
		exit;

	}

	//Emite uma mensagem de erro se o e-mail nao for preenchido
	if (!isset($_POST['email']) || $_POST['email'] == '') {

		User::setErrorRegister("Preencha o seu e-mail.");
		header("Location: /login");
		exit;

	}

	//Emite uma mensagem de erro se a senha nao for preenchida
	if (!isset($_POST['password']) || $_POST['password'] == '') {

		User::setErrorRegister("Preencha a sua senha.");
		header("Location: /login");
		exit;

	}

	//Emite uma mensagem de erro se o e-mail ja existir no banco de dados
	if (User::checkLoginExist($_POST['email']) === true) {

		User::setErrorRegister("Este endereço de e-mail já está sendo usado por outro usuário.");
		header("Location: /login");
		exit;

	}

	$user = new User();

	$user->setData([
		'inadmin'=>0,
		'deslogin'=>$_POST['email'],
		'desperson'=>$_POST['name'],
		'desemail'=>$_POST['email'],
		'despassword'=>$_POST['password'],
		'nrphone'=>$_POST['phone']
	]);

	$user->save();

	User::login($_POST['email'], $_POST['password']);

	header('Location: /checkout');
	exit;

});

$app->get("/forgot", function() { //Rota que renderiza a pagina que recupera a senha do usuario

	$page = new Page();

	$page->setTpl("forgot");

});

$app->post("/forgot", function() { //Rota que faz a recuperacao da senha do usuario

	$user = User::getForgot($_POST["email"], false);
	
	header("Location: /forgot/sent");
	exit;

});

$app->get("/forgot/sent", function() { //Rota que exibe a confirmacao do envio do email de recuperacao de email

	$page = new Page();

	$page->setTpl("forgot-sent");

});

$app->get("/forgot/reset", function() { //Rota que exibe o campo de restauracao da senha

	$user = User::validForgotDecrypt($_GET["code"]);

	$page = new Page ();

	$page->setTpl("forgot-reset", array(
		"name"=>$user["desperson"],
		"code"=>$_GET["code"]
	));

});

$app->post("/forgot/reset", function() { //Restaura a senha do usuario mantendo um hash no banco de dados

	$forgot = User::validForgotDecrypt($_POST["code"]);

	User::setForgotUsed($forgot["idrecovery"]);

	$user = new User();

	$user->get((int)$forgot["iduser"]);

	$password = User::getPasswordHash($_POST["password"]);

	$user->setPassword($password);

	$page = new Page ();

	$page->setTpl("forgot-reset-success");

});

?>