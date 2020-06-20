<?php 

require_once("vendor/autoload.php");

use \Slim\Slim;
use Hcode\Page;
use Hcode\PageAdmin;

$app = new Slim();

$app->config('debug', true);

$app->get('/', function() {
	
	$page = new Page(); //chama o metodo __construct e adiciona o "header" na tela

	$page->setTpl("index"); //carrega o conteudo da pagina
						//limpa a memoria, chama o metodo __destruct e adiciona o "footer" na tela
});

$app->get('/admin', function() {
	
	$page = new PageAdmin(); //chama o metodo __construct e adiciona o "header" do admin na tela

	$page->setTpl("index"); //carrega o conteudo da pagina
						//limpa a memoria, chama o metodo __destruct e adiciona o "footer" do admin na tela
});

$app->run();

 ?>