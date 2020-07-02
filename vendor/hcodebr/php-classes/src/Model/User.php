<?php

namespace Hcode\Model;

use \Hcode\DB\Sql;
use \Hcode\Model;
use \Hcode\Mailer;

class User extends Model {

    const SESSION = "User";
    const SECRET = "HcodePhp7_Secret";
    const SECRET_IV = "HcodePhp7_Secret_IV";
    const ERROR = "UserError";
    const ERROR_REGISTER = "UserErrorRegister";
    const SUCCESS = "UserSuccess";

    //Verifica se a sessao do usuario ainda esta ativa mesmo se ele sair so site
    public static function getFromSession() {

        $user = new User();

        if (isset($_SESSION[User::SESSION]) && (int)$_SESSION[User::SESSION]['iduser'] > 0) {
        
            $user->setData($_SESSION[User::SESSION]);

        }

        return $user;
        
    }

    //Verifica se o usuario esta logado e se eh admin
    public static function checkLogin($inadmin = true) {

        if (
            !isset($_SESSION[User::SESSION])
            ||
            !$_SESSION[User::SESSION]
            ||
            !(int)$_SESSION[User::SESSION]["iduser"] > 0
        ) {

            //Nao esta logado
            return false;

        } else {

            if ($inadmin === true && (bool)$_SESSION[User::SESSION]['inadmin'] === true) {

                //Esta logado e eh admin
                return true;

            } else if ($inadmin === false) {

                //Esta logado mas n eh admin
                return true;

            } else {

                //Nao esta logado
                return false;

            }

        }

    }

    //Realiza o login do usuario comparando o input com o banco de dados
    public static function login ($login, $password) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_users a INNER JOIN tb_persons b ON a.idperson = b.idperson
        WHERE deslogin = :LOGIN", array(
            ":LOGIN"=>$login
        ));

        if (count($results) === 0) {

            throw new \Exception("Usuario inexistente ou senha invalida.");

        }

        $data = $results[0];

        if (password_verify($password, $data["despassword"]) === true) {

            $user = new User();

            $user->setData($data);

            $_SESSION[User::SESSION] = $user->getValues();

            return $user;

        } else {

            throw new \Exception("Usuario inexistente ou senha invalida.");

        }

    }

    //Verifica o login do usuario
    public static function verifyLogin($inadmin = true) {

        if (!User::checkLogin($inadmin)) {

            if($inadmin) {
                header("Location: /admin/login");

            } else {
                header("Location: /login");
            }
            exit;

        }   

    }

    //Finaliza a sessao do usuario e faz o logout
    public static function logout() {

        $_SESSION[User::SESSION] = NULL;

    }

    //Lista os dados do usuario
    public static function listAll () {

        $sql = new Sql();

        //Junta e exibe informacoes de duas tabelas com dados de um so usuario
        return $sql->select("SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) ORDER BY b.desperson");

    }

    //Salva os dados cadastrados no banco de dados
    public function save() { 

        $sql = new Sql();

        $results = $sql->select("CALL sp_users_save(:desperson, :deslogin, :despassword, :desemail, :nrphone, :inadmin)", 
            array(
            ":desperson"=>$this->getdesperson(),
            ":deslogin"=>$this->getdeslogin(),
            ":despassword"=>User::getPasswordHash($this->getdespassword()),
            ":desemail"=>$this->getdesemail(),
            ":nrphone"=>$this->getnrphone(),
            ":inadmin"=>$this->getinadmin(),
        ));

        $this->setData($results[0]);

    }

    //Exibe as informacoes do usuario por meio de seu id de usuario
    public function get ($iduser) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_users a INNER JOIN tb_persons b USING(idperson) WHERE a.iduser = :iduser", 
            array(
            ":iduser"=>$iduser
        ));

        $this->setData($results[0]);
    }

    //Altera os dados cadastrados no banco de dados
    public function update() { 

        $sql = new Sql();

        $results = $sql->select("CALL sp_usersupdate_save(:iduser, :desperson, :deslogin, :despassword, :desemail, :nrphone, :inadmin)", 
            array(
            ":iduser"=>$this->getiduser(),
            ":desperson"=>$this->getdesperson(),
            ":deslogin"=>$this->getdeslogin(),
            ":despassword"=>$this->getdespassword(),
            ":desemail"=>$this->getdesemail(),
            ":nrphone"=>$this->getnrphone(),
            ":inadmin"=>$this->getinadmin(),
        ));

        $this->setData($results[0]);

    }

    //Deleta um usuario
    public function delete() {

        $sql = new Sql();

        $sql->query("CALL sp_users_delete(:iduser)", array(
            ":iduser"=>$this->getiduser()
        ));

    }

    //Recupera a senha de um usuario, verificando se o seu email existe no banco de dados e registra seu nome e
    // seu ip, codificando o seu id de recuperacao e enviando um email com este mesmo id
    public static function getForgot($email, $inadmin = true) {

        $sql = new Sql();

        $results = $sql->select("
        SELECT *
        FROM tb_persons a
        INNER JOIN tb_users b USING(idperson)
        WHERE a.desemail = :email;
        ", array(
            ":email"=> $email
        ));

        if (count($results) === 0) {
            
            throw new \Exception("Não foi possível recuperar a senha.");
        
        } else {

            $data = $results[0];

            $results2 = $sql->select("CALL sp_userspasswordsrecoveries_create(:iduser, :desip)", array(
                ":iduser"=>$data["iduser"],
                ":desip"=>$_SERVER["REMOTE_ADDR"]
            ));

            if (count($results2) === 0) {

                throw new \Exception("Não foi possível recuperar a senha");

            } else {

                $dataRecovery = $results2[0];

                $code = openssl_encrypt($dataRecovery['idrecovery'], 'AES-128-CBC', pack("a16", User::SECRET), 0, pack("a16", User::SECRET_IV));

                $code = base64_encode($code);

                if ($inadmin === true) {
                    $link = "http://www.hcodecommerce.com.br/admin/forgot/reset?code=$code";
                }else {
                    $link = "http://www.hcodecommerce.com.br/forgot/reset?code=$code";
                }

                $mailer = new Mailer($data["desemail"], $data["desperson"], "Redefinir Senha da Hcode Store", "forgot", array(
                    "name"=>$data["desperson"],
                    "link"=>$link
                ));

                $mailer->send();

                return $data;

            }

        }

    }

    //Recebe o id da sessao de recuperacao de senha, o decodifica, compara e o valida, verifica se e seguro este usuario recuperar a senha
    public static function validForgotDecrypt($code) {

        $code = base64_decode($code);

        $idrecovery = openssl_decrypt($code, 'AES-128-CBC', pack("a16", User::SECRET), 0, pack("a16", User::SECRET_IV));

        $sql = new Sql();

        $results = $sql->select("
            SELECT * 
            FROM tb_userspasswordsrecoveries a
            INNER JOIN tb_users b USING(iduser)
            INNER JOIN tb_persons c USING(idperson)
            WHERE 
                a.idrecovery = :idrecovery
                AND
                a.dtrecovery IS NULL
                AND
                DATE_ADD(a.dtregister, INTERVAL 1 HOUR) >= NOW();
        ", array(
            ":idrecovery"=>$idrecovery
        ));


        if (count($results) === 0) {

            throw new \Exception("Não foi possível recuperar a senha.");

        } else {

            return $results[0];

        }

    }

    //Insere a data de recuperacao da senha no banco de dados
    public static function setForgotUsed($idrecovery) {

        $sql = new Sql();

        $sql->query("UPDATE tb_userspasswordsrecoveries SET dtrecovery = NOW() WHERE idrecovery = :idrecovery", array(
            ":idrecovery"=>$idrecovery
        ));

    }

    //Insere a nova senha recuperada no banco de dados
    public function setPassword($password) {

        $sql = new Sql();

        $sql->query("UPDATE tb_users SET despassword = :password WHERE iduser = :iduser", array(
            ":password"=>$password,
            ":iduser"=>$this->getiduser()
        ));

    }

    //Verifica se o login ja existe
    public static function checkLoginExists($login) {

        $sql = new Sql();

        $results = $sql->select("SELECT * FROM tb_users WHERE deslogin = :deslogin", [
            'deslogin'=>$login
        ]);

        return (count($results) > 0);

    }

    //Converte o password recebido em hash
    public static function getPasswordHash($password) {

        return password_hash($password, PASSWORD_DEFAULT, [
            'cost'=>12
        ]);

    }

    //Atribui a mensagem de erro do usuario a uma variavel
    public static function setError($msg) {

        $_SESSION[User::ERROR] = $msg;

    }

    //Retorna a mensagem de erro do usuario
    public static function getError() {

        $msg = (isset($_SESSION[User::ERROR]) && $_SESSION[User::ERROR]) ? $_SESSION[User::ERROR] : '';

        User::clearError();

        return $msg;

    }

    //Limpa a mensagem de erro do usuario
    public static function clearError() {

        $_SESSION[User::ERROR] = NULL;

    }

    //Atribui a mensagem de sucesso a uma variavel
    public static function setSuccess($msg) {

        $_SESSION[User::SUCCESS] = $msg;

    }

    //Retorna a mensagem de sucesso
    public static function getSuccess() {

        $msg = (isset($_SESSION[User::SUCCESS]) && $_SESSION[User::SUCCESS]) ? $_SESSION[User::SUCCESS] : '';

        User::clearSuccess();

        return $msg;

    }

    //Limpa a mensagem de sucesso
    public static function clearSuccess() {

        $_SESSION[User::SUCCESS] = NULL;

    }

    //Atribui a mensagem de erro no registro
    public static function setErrorRegister($msg) {

        $_SESSION[User::ERROR_REGISTER] = $msg;

    }

    //Recebe a mensagem de erro no registro
    public static function getErrorRegister() {

        $msg = (isset($_SESSION[User::ERROR_REGISTER]) && $_SESSION[User::ERROR_REGISTER]) ? $_SESSION[User::ERROR_REGISTER] : '';

        User::clearErrorRegister();

        return $msg;

    }

    //Limpa a mensagem de erro do registro
    public static function clearErrorRegister() {

        $_SESSION[User::ERROR_REGISTER] = NULL;

    }

    public function getOrders() {

        $sql = new Sql();

        $results = $sql->select("SELECT * 
			FROM tb_orders a 
			INNER JOIN tb_ordersstatus b USING(idstatus) 
			INNER JOIN tb_carts c USING(idcart)
			INNER JOIN tb_users d ON d.iduser = a.iduser
			INNER JOIN tb_addresses e USING(idaddress)
			INNER JOIN tb_persons f ON f.idperson = d.idperson
			WHERE a.iduser = :iduser
		", [
			':iduser'=>$this->getiduser()
		]);

        return $results;

    }

}

?>