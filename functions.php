<?php

use \Hcode\Model\User;

function formatPrice($vlprice) { //Muda o formato do preco para o padrao BR

    return number_format($vlprice, 2, ",", ".");

}

function checkLogin($inadmin = true) { //Retorna a funcao checkLogin() da classe User

    return User::checkLogin($inadmin);

}

function getUserName() { //Recebe o nome do usuario

    $user = User::getFromSession();

    return $user->getdesperson();

}

?>