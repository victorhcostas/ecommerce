<?php

use \Hcode\PageAdmin;
use \Hcode\Model\User;
use \Hcode\Model\Order;
use \Hcode\Model\OrderStatus;

$app->get("/admin/orders/:idorder/status", function($idorder) { //Exibe a tela de status do pedido

    User::verifyLogin();

    $order = new Order();

    $order->get((int)$idorder);

    $page = new PageAdmin();

    $page->setTpl("order-status", [
        'order'=>$order->getValues(),
        'status'=>OrderStatus::listAll(),
        'msgSuccess'=>Order::getSuccess(),
        "msgError"=>Order::getError()
    ]);

});

$app->post("/admin/orders/:idorder/status", function($idorder) { //Muda o status do pedido

    User::verifyLogin();

    if (!isset($_POST['idstatus']) || !(int)$_POST['idstatus'] > 0) {
        Order::setError("Informe o status atual.");
        header("Location: /admin/orders/" . $idorder . "/status");
        exit;
    }

    $order = new Order();

    $order->get((int)$idorder);

    $order->setidstatus((int)$_POST['idstatus']);

    $order->save();

    Order::setSuccess("Status atualizado.");

    header("Location: /admin/orders/" . $idorder . "/status");
    exit;

});

$app->get("/admin/orders/:idorder/delete", function($idorder) { //Exclui um pedido

    User::verifyLogin();

    $order = new Order();

    $order->get((int)$idorder);

    $order->delete();

    header("Location: /admin/orders");
    exit;

});

$app->get("/admin/orders/:idorder", function($idorder) { //Exibe a tela de detalhes do pedido especifico

    User::verifyLogin();

    $order = new Order();

    $order->get((int)$idorder);

    $cart = $order->getCart();

    $page = new PageAdmin();

    $page->setTpl("order", [
        'order'=>$order->getValues(),
        'cart'=>$cart->getValues(),
        'products'=>$cart->getProducts()
    ]);

});

$app->get("/admin/orders", function() { //Exibe a tela dos pedidos
										//e faz a busca se uma palavra for enviada
    User::verifyLogin();

    $search = (isset($_GET['search'])) ? $_GET['search'] : "";
	$page = (isset($_GET['page'])) ? $_GET['page'] : 1;
	
	if ($search != '') {

		$pagination = Order::getPageSearch($search, $page);

	} else {

		$pagination = Order::getPage($page);

	}

	$pages = [];

	for ($x = 0; $x < $pagination['pages']; $x++) {

		array_push($pages, [
			'href'=>'/admin/orders?' . http_build_query([
				'page'=>$x+1,
				'search'=>$search
			]),
			'text'=>$x+1
		]);

	}

    $page = new PageAdmin();

    $page->setTpl("orders", [
        "orders"=>$pagination['data'],
		"search"=>$search,
		"pages"=>$pages
    ]);

});

?>