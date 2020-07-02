<?php

namespace Hcode;

//Incrementa o __construct() de Page() com os dados e a ROTA da administracao, ou seja, constroi a pagina da Administracao
class PageAdmin extends Page { 

    public function __construct($opts = array(), $tpl_dir = "/views/admin/") {

        parent::__construct($opts, $tpl_dir);

    }

}

?>