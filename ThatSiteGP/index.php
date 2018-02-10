<?php
session_start();
?>
<!DOCTYPE html>
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->  
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->  
<!--[if !IE]><!--> <html lang="ru"> <!--<![endif]-->  
<head>
    <title>BigBazewMod</title>
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
    <div class="menu">BigBazewMod-Control Panel Site</div>
    <div class="wrapper">
        <div class="sidebar-wrapper">
            <div class="profile-container">
                <?php $_SESSION['skin']; $_SESSION['email']; $_SESSION['name'];?>
			     <?php
			     if (empty($_SESSION['email']) or empty($_SESSION['id']))
				{
				?>
				<img class="profile" src="assets/images/profile.png" alt="" />
                <form action="checkpl.php" method="post">
                    <p><input type="email" name="email" placeholder = "Емеил"/> </p>
                    <p><input type="text" name="password" placeholder = "Пароль"/></p>
                    <p><input name="Enter" value="Ввойти" type="submit"/></p>
                </form>
				<?php
				}
				else
				{
				?>
                    <h1 class="name">Имя : <?php echo($_SESSION['name']);?></h1>
                    <h1 class="name">Ид : <?php echo($_SESSION['id']);?></h1>
					<img class="profilesk" width = "140px" height = "400px" src="assets/images/skins/<?php echo($_SESSION["skin"]); ?>.png" alt="" />
                    <br>Деньги : <?php echo($_SESSION['money']);?><i class="moneys">$</i>
                    <br>Дата : <?php echo($_SESSION['date']);?>
                    <form action="checkpl.php" method="post">
                    <p><input name="Outlook" value="Выход" type="submit"/></p>
                </form>
                <?php 
				}
				?>
            </div><!--//profile-container-->
            
            <div class="contact-container container-block">
                <ul class="list-unstyled contact-list">
                    <li class="email"><i class="fa fa-envelope"></i><a href="mailto: ermakl@meta.ua">Написать администрации</a></li>
                    <li class="phone"><i class="fa fa-phone"></i><a href="tel:ermakl2">Связь в дискорд</a></li>
                    <li class="website"><i class="fa fa-globe"></i><a href="index.php" target="_blank">BigBazewMod</a></li>
					<li class="website"><i class="fa fa-globe"></i><a href="http://127.0.0.1/openserver/phpmyadmin/index.php" target="_blank">MySQL</a></li>	
                </ul>
            </div><!--//contact-container-->

            
        </div><!--//sidebar-wrapper-->
        <div class="main-wrapper">
            
            <section class="section summary-section">
                <h2 class="section-title"><i class="fa fa-user"></i>О сервере , и сайте</h2>
                <div class="summary">
                    <p>Сервер и сайт были сделаны в розвлекательном стиле , и для тех же целей</p>
                </div><!--//summary-->
            </section><!--//section-->
            
            <section class="section experiences-section">
                <h2 class="section-title"><i class="fa fa-briefcase"></i>Новости</h2>
                
                <div class="item">
                    <div class="meta">
                        <div class="upper-row">
                            <h3 class="job-title">Дизаин сайта-панели</h3>
                            <div class="time">Сегодня</div>
                        </div><!--//upper-row-->
                        <div class="company">Добавил:ermakl</div>
                    </div><!--//meta-->
                    <div class="details">
                        <p>Уже работаю над дизаном и панелькой</p>
                    </div><!--//details-->
                </div><!--//item-->
                
            </section><!--//section-->
            
            <section class="section projects-section">
                <h2 class="section-title"><i class="fa fa-archive"></i>Projects</h2>
                <div class="intro">
                    <p>You can list your side projects or open source libraries in this section. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum et ligula in nunc bibendum fringilla a eu lectus.</p>
                </div><!--//intro-->
                <div class="item">
                    <span class="project-title"><a href="#hook">Velocity</a></span> - <span class="project-tagline">A responsive website template designed to help startups promote, market and sell their products.</span>
                    
                </div><!--//item-->
                <div class="item">
                    <span class="project-title"><a href="http://themes.3rdwavemedia.com/website-templates/responsive-bootstrap-theme-web-development-agencies-devstudio/" target="_blank">DevStudio</a></span> - 
                    <span class="project-tagline">A responsive website template designed to help web developers/designers market their services. </span>
                </div><!--//item-->
            </section><!--//section-->
            
            <section class="skills-section section">
                <h2 class="section-title"><i class="fa fa-rocket"></i>Стадия разроботки</h2>
                <div class="skillset">        
                    <div class="item">
                        <h3 class="level-title">Сервер</h3>
                        <div class="level-bar">
                            <div class="level-bar-inner" data-level="1%">
                            1%</div>                                     
                        </div><!--//level-bar-->                                 
                    </div><!--//item-->
                    <div class="item">
                        <h3 class="level-title">Сайт</h3>
                        <div class="level-bar">
                            <div class="level-bar-inner" data-level="63%">
                            63%</div>                                     
                        </div><!--//level-bar-->                                 
                    </div><!--//item-->
                </div>  
            </section><!--//skills-section-->
            
        </div><!--//main-body-->
    </div>
 
    <footer class="footer">
        <div class="text-center">
                <!--/* This template is released under the Creative Commons Attribution 3.0 License. Please keep the attribution link below when using for your own project. Thank you for your support. :) If you'd like to use the template without the attribution, you can check out other license options via our website: themes.3rdwavemedia.com */-->
                <small class="copyright">Design for BBZ by Ermakl</small>
        </div><!--//container-->
    </footer><!--//footer-->
 
    <!-- Javascript -->          
    <script type="text/javascript" src="assets/plugins/jquery-1.11.3.min.js"></script>
    <script type="text/javascript" src="assets/plugins/bootstrap/js/bootstrap.min.js"></script>    
    <!-- custom js -->
    <script type="text/javascript" src="assets/js/main.js"></script>            
</body>
</html> 

