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

        Category::updateFile();

    }

    //Retorna os dados da categoria
    public function get($idcategory) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_categories WHERE idcategory = :idcategory", [
            ':idcategory'=>$idcategory
        ]);

        $this->setData($results[0]);

    }

    //Deleta uma categoria
    public function delete() {

        $sql = new Sql();

        $sql->query("DELETE FROM tb_categories WHERE idcategory = :idcategory", [
            ":idcategory"=>$this->getidcategory()
        ]);

        Category::updateFile();

    }

    //Adiciona dinamicamente ao menu do site as categorias adicionadas ao banco de dados
    public static function updateFile() {

        $categories = Category::listAll();

        $html = [];

        foreach ($categories as $row) {
            array_push($html, '<li><a href="/categories/'.$row['idcategory'].'">'.$row['descategory']. '</a></li>');
        }

        file_put_contents($_SERVER['DOCUMENT_ROOT'] . DIRECTORY_SEPARATOR . "views" . DIRECTORY_SEPARATOR . "categories-menu.html", implode('', $html));

    }

    //Retorna os produtos relacionados a uma referida categoria
    public function getProducts($related = true) {

        $sql = new Sql();

        if ($related === true) {

            return $sql->select("
                SELECT * FROM tb_products WHERE idproduct IN (
                    SELECT a.idproduct
                    FROM  tb_products a
                    INNER JOIN tb_productscategories b ON a.idproduct = b.idproduct
                    WHERE b.idcategory = :idcategory
                );
            ", [
               ':idcategory'=>$this->getidcategory()
            ]);

        } else {

            return $sql->select("
                SELECT * FROM tb_products WHERE idproduct NOT IN (
                    SELECT a.idproduct
                    FROM  tb_products a
                    INNER JOIN tb_productscategories b ON a.idproduct = b.idproduct
                    WHERE b.idcategory = :idcategory
                );
            ", [
                ':idcategory'=>$this->getidcategory()
            ]);

        }

    }

    //Adiciona um produto a categoria especificada
    public function addProduct(Product $product) {

        $sql = new Sql();

        $sql->query("INSERT INTO tb_productscategories (idcategory, idproduct) VALUES (:idcategory, :idproduct)", [
            ':idcategory'=>$this->getidcategory(),
            ':idproduct'=>$product->getidproduct()
        ]);

    }

    //Remove um produto da categoria especificada
    public function removeProduct(Product $product) {

        $sql = new Sql();

        $sql->query("DELETE FROM tb_productscategories WHERE idcategory = :idcategory AND idproduct = :idproduct", [
            ':idcategory'=>$this->getidcategory(),
            ':idproduct'=>$product->getidproduct()
        ]);

    }

}

?>