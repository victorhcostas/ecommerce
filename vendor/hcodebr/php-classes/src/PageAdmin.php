<?php

namespace Hcode;

class PageAdmin extends Page { //Incrementa o __construct() de Page() com os dados e a ROTA da administracao

    public function __construct($opts = array(), $tpl_dir = "/views/admin/") {

        parent::__construct($opts, $tpl_dir);

    }

}

?>