<?php

use \Hcode\Page;
use \Hcode\Model\Product;
use \Hcode\Model\Category;

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

$app->get("/products/:desurl", function($desurl) {

	$product = new Product();

	$product->getFromURL($desurl);

	$page = new Page();

	$page->setTpl("product-detail", [
		'product'=>$product->getValues(),
		'categories'=>$product->getCategories()
	]);

});

?>