<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Model\Cart;

class Order extends Model {

	const SUCCESS = "Order-Success";
	const ERROR = "Order-Error";

    public function save() { //Salva os dados de um novo pedido no banco de dados

		$sql = new Sql();

		$results = $sql->select("CALL sp_orders_save(:idorder, :idcart, :iduser, :idstatus, :idaddress, :vltotal)", [
			':idorder'=>$this->getidorder(),
			':idcart'=>$this->getidcart(),
			':iduser'=>$this->getiduser(),
			':idstatus'=>$this->getidstatus(),
			':idaddress'=>$this->getidaddress(),
			':vltotal'=>$this->getvltotal()
		]);

		if (count($results) > 0) {
			$this->setData($results[0]);
		}

    }
    
    public function get($idorder) { //Retorna todas as informacoes de um pedido

		$sql = new Sql();

		$results = $sql->select("SELECT * 
			FROM tb_orders a 
			INNER JOIN tb_ordersstatus b USING(idstatus) 
			INNER JOIN tb_carts c USING(idcart)
			INNER JOIN tb_users d ON d.iduser = a.iduser
			INNER JOIN tb_addresses e USING(idaddress)
			INNER JOIN tb_persons f ON f.idperson = d.idperson
			WHERE a.idorder = :idorder
		", [
			':idorder'=>$idorder
		]);

		if (count($results) > 0) {
			$this->setData($results[0]);
		}

	}

	public static function listAll() { //Lista todos os pedidos salvos na loja

		$sql = new Sql();

		return $sql->select("SELECT * 
			FROM tb_orders a 
			INNER JOIN tb_ordersstatus b USING(idstatus) 
			INNER JOIN tb_carts c USING(idcart)
			INNER JOIN tb_users d ON d.iduser = a.iduser
			INNER JOIN tb_addresses e USING(idaddress)
			INNER JOIN tb_persons f ON f.idperson = d.idperson
			ORDER BY a.dtregister DESC
		");

	}

	public function delete() { //Exclui um pedido da lista

		$sql = new Sql();

		$sql->query("DELETE FROM tb_orders WHERE idorder = :idorder", [
			':idorder'=>$this->getidorder()
		]);

	}
	
	
	public function getCart():Cart { //Retorna as informacoes do carrinho utilizado no pedido, por meio do seu "idcart"
		$cart = new Cart();

		$cart->get((int)$this->getidcart());

		return $cart;

	}

	//Atribui a mensagem de erro do usuario a uma variavel
	public static function setError($msg) {

		$_SESSION[Order::ERROR] = $msg;

	}

	//Retorna a mensagem de erro do usuario
	public static function getError() {

		$msg = (isset($_SESSION[Order::ERROR]) && $_SESSION[Order::ERROR]) ? $_SESSION[Order::ERROR] : '';

		Order::clearError();

		return $msg;

	}

	//Limpa a mensagem de erro do usuario
	public static function clearError() {

		$_SESSION[Order::ERROR] = NULL;

	}

	//Atribui a mensagem de sucesso a uma variavel
	public static function setSuccess($msg) {

		$_SESSION[Order::SUCCESS] = $msg;

	}

	//Retorna a mensagem de sucesso
	public static function getSuccess() {

		$msg = (isset($_SESSION[Order::SUCCESS]) && $_SESSION[Order::SUCCESS]) ? $_SESSION[Order::SUCCESS] : '';

		Order::clearSuccess();

		return $msg;

	}

	//Limpa a mensagem de sucesso
	public static function clearSuccess() {

		$_SESSION[Order::SUCCESS] = NULL;

	}

}

?>