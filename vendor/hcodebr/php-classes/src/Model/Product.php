<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;

class Product extends Model {

    //Lista os dados de todas as categorias
    public static function listAll () {

        $sql = new Sql();

        //Exibe as informacoes de uma categoria
        return $sql->select("SELECT * FROM tb_products ORDER BY desproduct");

    }

    //Cria uma nova categoria
    public function save() {

        $sql = new Sql();

        $results = $sql->select("CALL sp_products_save(:idproduct, :desproduct, :vlprice, :vllength, :vlwidth, :vlheight, :vlweight, :desurl)",
         array(
            ":idproduct"=>$this->getidproduct(),
            ":desproduct"=>$this->getdesproduct(),
            ":vlprice"=>$this->getvlprice(),
            ":vllength"=>$this->getvllength(),
            ":vlwidth"=>$this->getvlwidth(),
            ":vlheight"=>$this->getvlheight(),
            ":vlweight"=>$this->getvlweight(),
            ":desurl"=>$this->getdesurl(),
        ));

        $this->setData($results[0]);

    }

    //Retorna os dados do produto
    public function get($idproduct) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_products WHERE idproduct = :idproduct", [
            ':idproduct'=>$idproduct
        ]);

        $this->setData($results[0]);

    }

    //Exclui um produto
    public function delete() {

        $sql = new Sql();

        $sql->query("DELETE FROM tb_products WHERE idproduct = :idproduct", [
            ":idproduct"=>$this->getidproduct()
        ]);

    }

    //Checa se o arquivo de foto do produto existe e retorna a imagem e, caso nao exista, atribui uma imagem padrao
    public function checkPhoto() {

        if (file_exists(
            $_SERVER['DOCUMENT_ROOT'] . DIRECTORY_SEPARATOR . 
        "res" . DIRECTORY_SEPARATOR .
        "site" . DIRECTORY_SEPARATOR .
        "img" . DIRECTORY_SEPARATOR .
        "products" . DIRECTORY_SEPARATOR . 
        $this->getidproduct() . ".jpg"
        )) {

            $url = "/res/site/img/products/" . $this->getidproduct() . ".jpg";

        } else {

            $url = "/res/site/img/product.jpg";

        }

        return $this->setdesphoto($url);

    }

    //Incrementa a checagem de imagens ao metodo parental getValues()
    public function getValues() {

        $this->checkPhoto();

        $values = parent::getValues();

        return $values;

    }

    public function setPhoto($file) { //Converte uma imagem enviada pelo usuario em jpeg(formato usado na programacao da nossa loja)

        //Pega o nome do arquivo e armazena a sua extensao
        $extension = explode(".", $file['name']);
        $extension = end($extension);

        //Instancia uma nova imagem baseando-se na extensao da imagem fornecida
        switch ($extension) {

            case "jpg":
            case "jpeg":
            $image = imagecreatefromjpeg($file["tmp_name"]);
            break;

            case "gif":
            $image = imagecreatefromgif($file["tmp_name"]);
            break;

            case "png":
            $image = imagecreatefrompng($file["tmp_name"]);
            break;

        }

        //Destino e nome da imagem criada
        $dest = $_SERVER['DOCUMENT_ROOT'] . DIRECTORY_SEPARATOR . 
        "res" . DIRECTORY_SEPARATOR .
        "site" . DIRECTORY_SEPARATOR .
        "img" . DIRECTORY_SEPARATOR . 
        "products" . DIRECTORY_SEPARATOR .
        $this->getidproduct() . ".jpg";

        //Cria a imagem
        imagejpeg($image, $dest);

        //Libera o espaco de memoria da imagem
        imagedestroy($image);

        $this->checkPhoto();

    }

}

?>