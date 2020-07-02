<?php

use \Hcode\Model\User;
use \Hcode\Model\Cart;

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

function getCartNrQtd() {

    $cart = Cart::getFromSession();

    $totals = $cart->getProductsTotals();

    return $totals['nrqtd'];

}

function getCartVlSubTotal() {

    $cart = Cart::getFromSession();

    $totals = $cart->getProductsTotals();

    return formatPrice($totals['vlprice']);

}

?>