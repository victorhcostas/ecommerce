<?php

use \Hcode\Model\User;
use \Hcode\Model\Cart;

function formatPrice($vlprice) { //Muda o formato do preco para o padrao BR

    return number_format($vlprice, 2, ",", ".");

}

function formatDate($date) { //Formata a data

    return date('d/m/Y', strtotime($date));

}

function checkLogin($inadmin = true) { //Retorna a funcao checkLogin() da classe User

    return User::checkLogin($inadmin);

}

function getUserName() { //Retorna o nome do usuario

    $user = User::getFromSession();

    return $user->getdesperson();

}

function getCartNrQtd() { //Retorna a quantidade total de produtos no carrinho

    $cart = Cart::getFromSession();

    $totals = $cart->getProductsTotals();

    return $totals['nrqtd'];

}

function getCartVlSubTotal() { //Retorna o valor total dos produtos do carrinho

    $cart = Cart::getFromSession();

    $totals = $cart->getProductsTotals();

    return formatPrice($totals['vlprice']);

}

?>