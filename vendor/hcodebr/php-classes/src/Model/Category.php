<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Mailer;

class Category extends Model {

    //Lista os dados de todas as categorias
    public static function listAll () {

        $sql = new Sql();

        //Exibe as informacoes de uma categoria
        return $sql->select("SELECT * FROM tb_categories ORDER BY descategory");

    }

    //Cria uma nova categoria
    public function save() {

        $sql = new Sql();

        $results = $sql->select("CALL sp_categories_save(:idcategory, :descategory)", array(
            ":idcategory"=>$this->getidcategory(),
            ":descategory"=>$this->getdescategory(),
        ));

        $this->setData($results[0]);

    }

    public function get($idcategory) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_categories WHERE idcategory = :idcategory", [
            ':idcategory'=>$idcategory
        ]);

        $this->setData($results[0]);

    }

    public function delete() {

        $sql = new Sql();

        $results = $sql->query("DELETE FROM tb_categories WHERE idcategory = :idcategory", [
            ":idcategory"=>$this->getidcategory()
        ]);

    }

}

?>