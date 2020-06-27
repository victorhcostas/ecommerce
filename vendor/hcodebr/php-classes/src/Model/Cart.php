<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Mailer;
use \Hcode\Model\User;

class Cart extends Model {

    const SESSION = "Cart";

    //Retorna o mesmo carrinho de uma sessao anterior para o usuario mesmo saindo do site, utilizando id de sessao
    public static function getFromSession() {

        $cart = new Cart();

        if (isset($_SESSION[Cart::SESSION]) && (int)$_SESSION[Cart::SESSION]['idcart'] > 0) {

            $cart->get((int)$_SESSION[Cart::SESSION]['idcart']);

        } else {

            $cart->getFromSessionID();

            if (!(int)$cart->getidcart() > 0) {

                $data = [
                    'dessessionid'=>session_id()
                ];

                if (User::checkLogin(false)) {

                    $user = User::getFromSession();

                    $data['iduser'] = $user->getiduser();

                }

                $cart->setData($data);

                $cart->save();

                $cart->setToSession();

            }

        }

        return $cart;

    }

    public function setToSession() {

        $_SESSION[Cart::SESSION] = $this->getValues();

    }

    //Retorna o ID da sessao relacionado ao carrinho, se ela existir
    public function getFromSessionID() {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_carts WHERE dessessionid = :dessessionid", [
            ':dessessionid'=>session_id()
        ]);

        if (count($results) > 0) {

            $this->setData($results[0]);

        }

    }

    //Retorna o id do carrinho, se ele existir
    public function get(int $idcart) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_carts WHERE idcart = :idcart", [
            ':idcart'=>$idcart
        ]);

        if (count($results) > 0) {

            $this->setData($results[0]);

        }

    }

    //Salva os dados de um carrinho no banco de dados
    public function save() {

        $sql = new Sql();

        $results = $sql->select("CALL sp_carts_save(:idcart, :dessessionid, :iduser, :deszipcode, :vlfreight, :nrdays)", [
            ':idcart'=>$this->getidcart(),
            ':dessessionid'=>$this->getdessessionid(),
            ':iduser'=>$this->getiduser(),
            ':deszipcode'=>$this->getdeszipcode(),
            ':vlfreight'=>$this->getvlfreight(),
            ':nrdays'=>$this->getnrdays(),
        ]);

        $this->setData($results[0]);

    }

}

?>