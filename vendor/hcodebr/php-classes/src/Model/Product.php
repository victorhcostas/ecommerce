<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Mailer;

class Product extends Model {

    //Lista os dados de todas as categorias
    public static function listAll () {

        $sql = new Sql();

        //Exibe as informacoes de uma categoria
        return $sql->select("SELECT * FROM tb_products ORDER BY desproduct");

    }

    //Recebe uma lista de dados e os trata conforme os metodos que queremos
    public static function checkList($list) { 

        foreach($list as &$row) {

            $p = new Product();
            $p->setData($row);
            $row = $p->getValues();

        }

        return $list;

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

    //Converte uma imagem enviada pelo usuario em jpeg(formato usado na programacao da nossa loja)
    public function setPhoto($file) { 

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

    //Retorna informacoes de um produto por meio de sua URL
    public function getFromURL($desurl) {

        $sql = new Sql();

        $rows = $sql->select("SELECT * FROM tb_products WHERE desurl = :desurl LIMIT 1", [
            ':desurl'=>$desurl
        ]);

        $this->setData($rows[0]);

    }

    //Retorna as categorias as quais um produto pertence
    public function getCategories() {

        $sql = new Sql();

        return $sql->select("SELECT * FROM tb_categories a 
            INNER JOIN tb_productscategories b ON a.idcategory = b.idcategory 
            WHERE b.idproduct = :idproduct
            ", [
                ':idproduct'=>$this->getidproduct()
            ]);

    }

    //Especifica o numero de produtos que aparecem numa pagina
    public static function getPage ($page = 1, $itemsPerPage = 4) {

        $start = ($page - 1) * $itemsPerPage;

        $sql = new Sql();

        $results = $sql->select("SELECT SQL_CALC_FOUND_ROWS *
            FROM tb_products
            ORDER BY desproduct
            LIMIT $start, $itemsPerPage;
        ");

        $resultTotal = $sql->select("SELECT FOUND_ROWS() AS nrtotal;");

        return [
            'data'=>$results,
            'total'=>(int)$resultTotal[0]["nrtotal"], 
            'pages'=>ceil($resultTotal[0]["nrtotal"] / $itemsPerPage) //A funcao ceil arredonda numeros inteiros para cima
        ];

    }

    //Faz uma busca e especifica o numero de produtos encontrados que aparecem numa pagina
    public static function getPageSearch ($search, $page = 1, $itemsPerPage = 4) {

        $start = ($page - 1) * $itemsPerPage;

        $sql = new Sql();

        $results = $sql->select("SELECT SQL_CALC_FOUND_ROWS *
            FROM tb_products 
            WHERE desproduct LIKE :search
            ORDER BY desproduct
            LIMIT $start, $itemsPerPage;
        ", [
            ':search'=>'%' . $search . '%'
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