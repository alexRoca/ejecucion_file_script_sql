<?php
		//Se puede usar "mysqli_connect" o "new mysqli", en ambos casos se cponecta a la base de datos usando SQLI
		//que permite realizar multiples script en un solo envio.
		
		//para usar este script se debe crear previamente una base de datos con el nombre "a_prueba"
		
		//$mysqli = mysqli_connect("127.0.0.1", "root", "123", "a_prueba");
		$mysqli = new mysqli("127.0.0.1", "root", "123", "a_prueba");

		$fileSQL = file_get_contents('C:\wamp64\www\ejecucion_file_script_sql\apiadministrador16-05-2020.sql');
		
		if ($mysqli->multi_query($fileSQL)) {
			echo 'se logro ejecutar los scripts';
		}else{
			echo 'no se logro ejecutar los scripts del archivo';
		}
		
		mysqli_close($mysqli);
		
		
		
		
		