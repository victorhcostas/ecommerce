<?php 
session_start(); //Inicio da sessao no site

require_once("vendor/autoload.php"); //Carrega o autoload do Composer

use \Slim\Slim; //Importa o Slim

$app = new Slim(); //Instancia um novo Slim Framework

$app->config('debug', true);

//Importa as rotas da aplicacao
require_once("functions.php");
require_once("site.php");
require_once("admin.php");
require_once("admin-users.php");
require_once("admin-categories.php");
require_once("admin-products.php");
require_once("admin-orders.php");


$app->run(); //Carrega a pagina

?>