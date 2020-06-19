<?php

namespace Hcode;

use Rain\Tpl;

class Page {

    private $tpl;
    private $options = [];
    private $defaults = [
        "data"=>[]
    ];

    //metodo construtor (executado primeiro)
    public function __construct($opts = array()) {

        //defaults sera sobrescrito sempre que houver um input de $opts
        //options recebe o array sobrescrito
        $this->options = array_merge($this->defaults, $opts);

        $config = array(
            "tpl_dir"       => $_SERVER["DOCUMENT_ROOT"] . "/ecommerce/views/",
            "cache_dir"     => $_SERVER["DOCUMENT_ROOT"] . "/ecommerce/views-cache/",
            "debug"         => false
        );

        Tpl::configure($config);

        $this->tpl = new Tpl;

        $this->setData($this->options["data"]);

        //exibe o cabecalho da pagina
        $this->tpl->draw("header");

    }

    //funcao que transfere os dados recebidos em um array
    private function setData($data = array()) {

        foreach ($data as $key => $value) {
            $this->tpl->assign($key, $value);
        }

    }

    //funcao que carrega o conteudo (css, scripts, etc) da pagina
    public function setTpl($name, $data = array(), $returnHTML = false ) {

        $this->setData($data);

        return $this->tpl->draw($name, $returnHTML);

    }
    
    //metodo destrutor (executado por ultimo)
    public function __destruct() {

        //exibe o rodape da pagina
        $this->tpl->draw("footer");

    }

}

?>