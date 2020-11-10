# kodexplorer-https

* 可道云kodexplorer，版本4.40，非kodbox，此容器支持https访问。

* 运行：docker run -d --name kodexplorer --restart always -p 81:80 -p 444:443 -v $your_data_dir:/var/www/html/ -v $your_ssl_dir:/ssl/ 33naisi/kodexplorer2

* 持久性数据：/var/www/html/ /ssl/。

* 端口：80 443。

* 变量： SERVERNAME="localhost.localdomain" PEM="ssl.pem" KEY="ssl.key"

* 如果要使用自己的证书，请使用"-v $yourDir/:/ssl/"指定ssl证书文件目录，使用"-e PEM=$yourPEMname -e KEY=$yourKEYname"指定你证书的名字，如果不适用-e参数，请把证书改名为默认ssl.pem和ssl.key。并在启动前请确认两个证书文件的目录和文件名,否则容器会因为找不到证书文件而启动时失败。

* 使用自己的域名请使用"-e SERVERNAME=$yourDomain"。 如果ssl证书不可信或者ssl证书和访问域名不一致，浏览器会提示证书异常。
