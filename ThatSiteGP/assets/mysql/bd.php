<?php 
/* Переменные для соединения с базой данных */ 
$hostname = "localhost";
$username = "root";
$password = "";
$db = "samp";
/* создать соединение */
mysql_connect($hostname,$username,$password) OR DIE("Не могу создать соединение ");
/* выбрать базу данных. Если произойдет ошибка - вывести ее */
mysql_select_db($db) or die(mysql_error());   ?>