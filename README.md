# Projeto E-commerce

Repositorio do meu primeiro projeto e-commerce

Projeto desenvolvido do zero no [Curso de PHP 7](https://www.udemy.com/curso-completo-de-php-7/) disponível na plataforma da Udemy e no site do [HTML5dev.com.br](https://www.html5dev.com.br/curso/curso-completo-de-php-7).

Template usado no projeto [Almsaeed Studio](https://almsaeedstudio.com)

/////////////////////*ERROR LOG*//////////////////////////////////

1-ERRO DE DIGITACAO (
    Page.php(35): digitei $this->tlp->draw("header")
    CORRECAO: o certo era digitar "tpl" e nao "tlp"
)

2-ERRO DE CHAMADA DE DIRETORIO (
    Page.php(24-25):    "tpl_dir"       => $_SERVER["DOCUMENT_ROOT"] . "/views/",
                        "cache_dir"     => $_SERVER["DOCUMENT_ROOT"] . "/views-cache/"
    A constante $_SERVER["DOCUMENT_ROOT"] chama a URL www.hcodecommerce.com.br, que aponta para
    o diretorio "htdocs", que nao possui os arquivos chamados

    CORRECAO: o diretorio "htdocs/ecommerce" tem os arquivos, entao devemos chama-lo 
    na URL www.hcodecommerce.com.br/ecommerce, deste modo:
        "tpl_dir"       => $_SERVER["DOCUMENT_ROOT"] . "/ecommerce/views/",
        "cache_dir"     => $_SERVER["DOCUMENT_ROOT"] . "/ecommerce/views-cache/",
)

3-ERRO DE CHAMADA DE ARQUIVOS (
    header.html, index.html, footer.html: varias tags "href" e "src" apontavam para diretorios
    que levavam aos arquivos de referencia, mas que quando chamados pela url, nao os encontravam

    CORRECAO: a url chama pelo diretorio local htdocs, bastou adicionar /ecommerce/ aos PATHS das
    referencias que os arquivos foram encontrados e renderizados no site
)