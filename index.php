<?php
		mysqli_report(MYSQLI_REPORT_STRICT | MYSQLI_REPORT_ALL);
		//Se puede usar "mysqli_connect" o "new mysqli", en ambos casos se cponecta a la base de datos usando SQLI
		//que permite realizar multiples script en un solo envio.
		
		//para usar este script se debe crear previamente una base de datos con el nombre "a_prueba"
		
		$estado=0;
		
		try {
		
			$mysqli = mysqli_connect("127.0.0.1", "root", "123", "a_prueba");
			
			//$mysqli = new mysqli("127.0.0.1", "root", "123", "a_prueba");
			$estado=1;
		} catch (mysqli_sql_exception $e) {
			echo "error al conexion : ".$e ." .";
		}
		
		if(!$fileSQL = @file_get_contents('C:\wamp64\www\ejecucion_file_script_sql\apiadministrador16-05-2020.sql')){
			echo "error al leer archivo.";
		}
		
		if($estado==1){
			
			try {
				if ($mysqli->multi_query($fileSQL)) {
					echo 'se logro ejecutar los scripts';
				}else{
					echo 'no se logro ejecutar los scripts del archivo';
				}
			} catch (mysqli_sql_exception $e) {
				echo "error ejecutar sql : ".$e ." .";
			}
			
			mysqli_close($mysqli);
		}
		
		
		
		
		
		