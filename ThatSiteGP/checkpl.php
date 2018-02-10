<?php 
	session_start(); 
	?>
<!DOCTYPE html>
<html lang="ru">

<head>
   <title>Авторизация</title>
    <!-- Meta -->
    <meta charset="windows-1251">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Responsive HTML5 Resume/CV Template for Developers">
    <meta name="author" content="Xiaoying Riley at 3rd Wave Media">    
    <link rel="shortcut icon" href="favicon.ico">  
    <link href='https://fonts.googleapis.com/css?family=Roboto:400,500,400italic,300italic,300,500italic,700,700italic,900,900italic' rel='stylesheet' type='text/css'>
    <!-- Global CSS -->
    <link rel="stylesheet" href="assets/plugins/bootstrap/css/bootstrap.min.css">   
    <!-- Plugins CSS -->
    <link rel="stylesheet" href="assets/plugins/font-awesome/css/font-awesome.css">
    
    <!-- Theme CSS -->  
    <link id="theme-style" rel="stylesheet" href="assets/css/styles.css">
    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
</head>
<body>
	<div class="wrapper">
		<div class="main-wrapper">
		<?php
		if(isset($_POST['Outlook'])) 
		{
			$_SESSION = array();
			?>
			<meta http-equiv="refresh" content="2; url=index.php">
			Вы упешно вышли из акаунта !
			<?php
			exit;
		}
		if (isset($_POST['Enter']))
		{
		if (isset($_POST['email'])) { $email = $_POST['email']; if ($email == '') { unset($email);} } //заносим введенный пользователем логин в переменную $login, если он пустой, то уничтожаем переменную
    if (isset($_POST['password'])) { $password=$_POST['password']; if ($password =='') { unset($password);} }
    //заносим введенный пользователем пароль в переменную $password, если он пустой, то уничтожаем переменную
 		if(empty($email)) //если пользователь не ввел логин или пароль, то выдаем ошибку и останавливаем скрипт
    {
    exit ("Введите емеил");
    }
    if(empty($password))
    {
    exit ("Введите пароль");
    }
    //если логин и пароль введены,то обрабатываем их, чтобы теги и скрипты не работали, мало ли что люди могут ввести
    $email = stripslashes($email);
    $email = htmlspecialchars($email);
		$password = stripslashes($password);
    $password = htmlspecialchars($password);
//удаляем лишние пробелы
    $email = trim($email);
    $password = trim($password);
// подключаемся к базе
    include ("assets/mysql/bd.php");// файл bd.php должен быть в той же папке, что и все остальные, если это не так, то просто измените путь 
 		$result = mysql_query("SELECT * FROM players WHERE Mail='$email'"); //извлекаем из базы все данные о пользователе с введенным mail
    $myrow = mysql_fetch_array($result);
    if (empty($myrow['Pass']))
    {
    //если пользователя с введенным логином не существует
    exit ("Извините, вы ввели неверный");
    }
    else {
    //если существует, то сверяем пароли
    $salt = "kaktus" + '\';
		$hashed = hash('sha256', $password+'\'. $salt );
		echo($myrow['Pass']);
		?><hr><?php
		echo(mb_strtoupper($hashed));
		?><hr><?php
		if (strcasecmp($hashed, $myrow['Pass']) == 0) 
		{
    //пароль верный, выполняем нужные действия
    //если пароли совпадают, то запускаем пользователю сессию! Можете его поздравить, он вошел!
    $_SESSION['email']=$myrow['Mail']; 
    $_SESSION['name']=$myrow['Name']; 
    $_SESSION['skin']=$myrow['Skin'];
    $_SESSION['money']=$myrow['Money'];
    $_SESSION['date']=$myrow['Date'];
    $_SESSION['id']=$myrow['ID'];//эти данные очень часто используются, вот их и будет "носить с собой" вошедший пользователь
    ?> <meta http-equiv="refresh" content="2; url=index.php"><?php
    echo "Вы успешно вошли на сайт! 
    <br>Если вас автоматически не перебросило , намите сюдa <a href='index.php'>Главная страница</a>";
    }
 else {
    //если пароли не сошлись

    exit ("Извините, введённый вами login или пароль неверный.");
    }
    }
  	}
    ?>
  </div>
	</div>
</body>
</html>