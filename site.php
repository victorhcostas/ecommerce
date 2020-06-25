<?php

use \Hcode\Page;
use \Hcode\Model\Category;

$app->get('/', function() {
	
	$page = new Page(); //chama o metodo __construct e adiciona o "header" na tela

	$page->setTpl("index"); //carrega o conteudo da pagina
						//limpa a memoria, chama o metodo __destruct e adiciona o "footer" na tela
});

$app->get("/categories/:idcategory", function($idcategory) { //Exibe a pagina de produtos de uma categoria especifica

	$category = new Category();

	$category->get((int)$idcategory);

	$page = new Page();

	$page->setTpl("category", [
		'category'=>$category->getValues(),
		'products'=>[]
	]);

});

?>