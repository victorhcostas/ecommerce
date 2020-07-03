<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Model\Cart;

class Order extends Model {

	const SUCCESS = "Order-Success";
	const ERROR = "Order-Error";

	//Salva os dados de um novo pedido no banco de dados
    public function save() { 

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
    
	//Retorna todas as informacoes de um pedido
    public function get($idorder) { 

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

	//Lista todos os pedidos salvos na loja
	public static function listAll() { 

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

	//Exclui um pedido da lista
	public function delete() { 

		$sql = new Sql();

		$sql->query("DELETE FROM tb_orders WHERE idorder = :idorder", [
			':idorder'=>$this->getidorder()
		]);

	}
	
	
	//Retorna as informacoes do carrinho utilizado no pedido, por meio do seu "idcart"
	public function getCart():Cart { 
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

	//Especifica o numero de pedidos que aparecem numa pagina
	public static function getPage ($page = 1, $itemsPerPage = 4) {

		$start = ($page - 1) * $itemsPerPage;

		$sql = new Sql();

		$results = $sql->select("SELECT SQL_CALC_FOUND_ROWS *
			FROM tb_orders a 
			INNER JOIN tb_ordersstatus b USING(idstatus) 
			INNER JOIN tb_carts c USING(idcart)
			INNER JOIN tb_users d ON d.iduser = a.iduser
			INNER JOIN tb_addresses e USING(idaddress)
			INNER JOIN tb_persons f ON f.idperson = d.idperson
			ORDER BY a.dtregister DESC
			LIMIT $start, $itemsPerPage;
		");

		$resultTotal = $sql->select("SELECT FOUND_ROWS() AS nrtotal;");

		return [
			'data'=>$results,
			'total'=>(int)$resultTotal[0]["nrtotal"], 
			'pages'=>ceil($resultTotal[0]["nrtotal"] / $itemsPerPage) //A funcao ceil arredonda numeros inteiros para cima
		];

	}

	//Faz uma busca e especifica o numero de pedidos encontrados que aparecem numa pagina
	public static function getPageSearch ($search, $page = 1, $itemsPerPage = 4) {

		$start = ($page - 1) * $itemsPerPage;

		$sql = new Sql();

		$results = $sql->select("SELECT SQL_CALC_FOUND_ROWS *
			FROM tb_orders a 
			INNER JOIN tb_ordersstatus b USING(idstatus) 
			INNER JOIN tb_carts c USING(idcart)
			INNER JOIN tb_users d ON d.iduser = a.iduser
			INNER JOIN tb_addresses e USING(idaddress)
			INNER JOIN tb_persons f ON f.idperson = d.idperson
			WHERE a.idorder = :id OR f.desperson LIKE :search
			ORDER BY a.dtregister DESC
			LIMIT $start, $itemsPerPage;
		", [
			':search'=>'%' . $search . '%',
			':id'=>$search
		]);

		$resultTotal = $sql->select("SELECT FOUND_ROWS() AS nrtotal;");

		return [
			'data'=>$results,
			'total'=>(int)$resultTotal[0]["nrtotal"], 
			'pages'=>ceil($resultTotal[0]["nrtotal"] / $itemsPerPage) //A funcao ceil arredonda numeros inteiros para cima
		];

	}

}

?>