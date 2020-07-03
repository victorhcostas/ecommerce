<?php

use \Hcode\PageAdmin;
use \Hcode\Model\User;
use \Hcode\Model\Category;
use \Hcode\Model\Product;

$app->get("/admin/categories", function() { //exibe a lista de categorias de produtos disponiveis

	User::verifyLogin();

	$search = (isset($_GET['search'])) ? $_GET['search'] : "";
	$page = (isset($_GET['page'])) ? $_GET['page'] : 1;
	
	if ($search != '') {

		$pagination = Category::getPageSearch($search, $page);

	} else {

		$pagination = Category::getPage($page, 3);

	}

	$pages = [];

	for ($x = 0; $x < $pagination['pages']; $x++) {

		array_push($pages, [
			'href'=>'/admin/categories?' . http_build_query([
				'page'=>$x+1,
				'search'=>$search
			]),
			'text'=>$x+1
		]);

	}

	$page = new PageAdmin();

	$page->setTpl("categories", [
		"categories"=>$pagination['data'],
		"search"=>$search,
		"pages"=>$pages
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

$app->get("/admin/categories/:idcategory", function($idcategory) { //Exibe a tela de alteracao de dados de uma categoria

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$page = new PageAdmin();

	$page->setTpl("categories-update", [
		'category'=>$category->getValues()
	]);

});

$app->post("/admin/categories/:idcategory", function($idcategory) { //Altera os dados de uma categoria

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$category->setData($_POST);

	$category->save();

	header('Location: /admin/categories');
	exit;

});

$app->get("/admin/categories/:idcategory/products", function($idcategory) { //Exibe a secao de produtos de uma categoria especifica

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$page = new PageAdmin();

	$page->setTpl("categories-products", [
		'category'=>$category->getValues(),
		'productsRelated'=>$category->getProducts(),
		'productsNotRelated'=>$category->getProducts(false)
	]);

}); 

$app->get("/admin/categories/:idcategory/products/:idproduct/add", function($idcategory, $idproduct) { //Adiciona um produto a categoria da pagina

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$product = new Product();

	$product->get((int)$idproduct);

	$category->addProduct($product);

	header("Location: /admin/categories/" . $idcategory . "/products");
	exit;

}); 

$app->get("/admin/categories/:idcategory/products/:idproduct/remove", function($idcategory, $idproduct) { //Remove um produto da categoria da pagina

	User::verifyLogin();

	$category = new Category();

	$category->get((int)$idcategory);

	$product = new Product();

	$product->get((int)$idproduct);

	$category->removeProduct($product);

	header("Location: /admin/categories/" . $idcategory . "/products");
	exit;

}); 

?>