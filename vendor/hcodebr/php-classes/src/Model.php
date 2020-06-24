<?php

namespace Hcode;

class Model {

    private $values = [];

    //Funcao que prepara os getters e os setters
    public function __call($name, $args) {

        $method = substr($name, 0, 3);
        $fieldName = substr($name, 3, strlen($name));

        switch ($method) {

            case "get":
                return (isset($this->values[$fieldName])) ? $this->values[$fieldName] : NULL;
            break;

            case "set":
                $this->values[$fieldName] = $args[0];
            break;    

        }

    }

    //Funcao que armazena os dados recebidos em um array
    public function setData($data = array()) {


        
        foreach ($data as $key => $value) {
            //usa-se as chaves para passar uma variavel dinamic  

            $this->{"set" . $key}($value);

        }
        

    }

    //Funcao que retorna os dados privados
    public function getValues() {

        return $this->values;

    }

}

?>