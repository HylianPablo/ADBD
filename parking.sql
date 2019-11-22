--Equipo 09

DROP TABLE Solicitud;
DROP TABLE Aparcamiento;
DROP TABLE Valoracion;
DROP TABLE Trabajador;
DROP TABLE ContratoAbono;
DROP TABLE ContratoLaboral
DROP TABLE Abono;
DROP TABLE PlazaResidencial;
DROP TABLE PlazaRotacional;
DROP TABLE Ticket;
DROP TABLE Vehiculo;
DROP TABLE Referencia;

CREATE DOMAIN ESTADO_SOLICITUD AS CHAR(15) 
	CHECK(VALUE IN('aceptada','pendiente', 'cancelada'));

CREATE DOMAIN TIPO_ABONO AS CHAR(15)
	CHECK(VALUE IN('conreserva', 'sinreserva-diurno', 'sinreserva-nocturno','cesion'));

CREATE DOMAIN CONTAMINANTE AS CHAR(15)
	CHECK(VALUE IN('CERO','ECO','C','B'));

CREATE DOMAIN TIPO_VEHICULO AS CHAR(15)
	CHECK(VALUE IN('automovil','autocaravana','motocicleta'));

CREATE ASSERTION nplazasres(
	CHECK (	(SELECT COUNT(*)
		FROM Solicitud S NATURAL JOIN Aparcamiento A
		WHERE (SELECT COUNT (*) FROM PlazaResidencial PR NATURAL JOIN Aparcamiento A) >0) =
		(SELECT COUNT(*) FROM Solicitud S NATURAL JOIN Aparcamiento A)));

CREATE ASSERTION tarifasmaximas(
	CHECK (SELECT * FROM Globales G, Aparcamiento A WHERE A.tarifaautomovil<=G.tarifamaxauto),
	CHECK (SELECT * FROM Globales G, Aparcamiento A WHERE A.tarifamotocicleta<=G.tarifamaxmoto),
	CHECK (SELECT * FROM Globales G, Aparcamiento A WHERE A.tarifaautocaravana<=G.tarifamaxcarav));

CREATE TABLE Globales(
	tarifamaxauto FLOAT,
	tarifamaxmoto FLOAT,
	tarifacarav FLOAT);

CREATE TABLE Valoracion(
	codigov CHAR(20),
	codigoparking CHAR(20), 
	descripcion CHAR(100), 
	PRIMARY KEY (codigov,codigoparking), 
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Solicitud(
	codigosolicitud CHAR(20), 
	nombre CHAR(20), 
	apellidos CHAR(80), 
       	nif CHAR(9), 
	domicilio CHAR(40), 
	acreditacionresidencia BOOLEAN, 
	fecha DATE, 
	estado ESTADO_SOLICITUD,
	codigoparking CHAR(20),
	UNIQUE (nif),
	CHECK (nplazasres),
	PRIMARY KEY  (codigosolicitud), 
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento,
	FOREIGN KEY (nombre) REFERENCES Usuario,	
	FOREIGN KEY (apellidos) REFERENCES Usuario,	
	FOREIGN KEY (nif) REFERENCES Usuario,	
	FOREIGN KEY (domicilio) REFERENCES Usuario);

CREATE TABLE Aparcamiento(
	codigoparking CHAR(20),
	numplazastotales INTEGER,
       	numplazasocupadas INTEGER, 
	espaciobicis BOOLEAN,
	espaciovmu BOOLEAN, 
	admisioncomerciante BOOLEAN, 
	tarifaautomovil FLOAT,
	tarifaautocarvana FLOAT,
	tarifamotocicleta FLOAT,
	PRIMARY KEY (codigoparking),
	CHECK (numplazastotales>0)
	CHECK (tarifasmaximas));

CREATE TABLE Trabajador(
	nombre CHAR(20), 
	apellidos CHAR(80), 
	nif CHAR(9), 
	domicilio CHAR(40),
	gestor BOOLEAN,
	PRIMARY KEY (nif));

CREATE TABLE Abono(
	numeroabono CHAR(20), 
	movsostenible BOOLEAN, 
	tipo TIPO_ABONO, 
	PRIMARY KEY (numeroabono));

CREATE TABLE ContratoLaboral(
	numcontrato CHAR(20),
	fechainicio DATE, 
	fechafin DATE, 
	codigoparking CHAR(20),
	nif CHAR(9),
	PRIMARY KEY (numcontrato,numeroparking,nif,numcontrato),
	FOREIGN KEY (numeroparking) REFERENCES Abono, 
	FOREIGN KEY (nif) REFERENCES Usuario);

CREATE TABLE ContratoAbono(
	numcontrato CHAR(20),
	fechainicio DATE, 
	fechafin DATE, 
	numeroabono CHAR(20),
	nif CHAR(9),
	PRIMARY KEY (numeroabono, nif,numcontrato),
	FOREIGN KEY (numeroabono) REFERENCES Abono, 
	FOREIGN KEY (nif) REFERENCES Usuario);

CREATE TABLE Usuario(
	nombre CHAR(20), 
	apellidos CHAR(80), 
	nif CHAR(9), 
	domicilio CHAR(40),
	residente BOOLEAN, 
	fianza FLOAT, 
	numcuotasnopagadas INTEGER, 
	pmr BOOLEAN,
	PRIMARY KEY (nif));

CREATE TABLE PlazaResidencial(
	coste FLOAT,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN, 
	personaespecial BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE PlazaRotacional(
	disuasorio BOOLEAN,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN, 
	personaespecial BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Ticket(
	horae TIME, 
	matricula CHAR(10),
	fecha DATE, 
	codiogparking CHAR(20), 
	precio FLOAT,
	horas TIME,
	PRIMARY KEY (horae, matricula, fecha),
	FOREIGN KEY (matricula) REFERENCES Vehiculo,
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Vehiculo(
	matricula CHAR(10),
	modelo CHAR(30),
	acreditacion BOOLEAN,
	distintivoambiental CONTAMINANTE,
	--distintivoambiental CHAR(30) CHECK(distintivo ambiental IN('ECO','B','C','OTRO')),
	tipo TIPO_VEHICULO,
	PRIMARY KEY (matricula));

CREATE TABLE Referencia(
	matricula CHAR(10),
	numeroabono CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	PRIMARY KEY (matricula, numeroabono),
	FOREIGN KEY (matricula) REFERENCES Vehiculo,
	FOREIGN KEY (numeroabono) REFERENCES Abono);

INSERT INTO Valoracion VALUES ('123456D8753277532','123456D','correcto');
INSERT INTO Valoracion VALUES ('123456D5319274742','123456D','malo');
INSERT INTO Valoracion VALUES ('398930Q3631404429','398930Q','correcto');
INSERT INTO Valoracion VALUES ('648509K8731387119','648509K','perfecto');
INSERT INTO Valoracion VALUES ('626873M3309084705','626873M','pesimo');

INSERT INTO Solicitud VALUES ('447986M74841277493','Juan','González Díez','71189567Q','Calle Luz, 8','true','2011-04-14','aceptada','447986M');
INSERT INTO Solicitud VALUES ('071831K77491833085','Marta','Martín De la Fuente','12438957J','Calle Mango, 34, Piso 2C','true','2013-08-24','aceptada','071831K');
INSERT INTO Solicitud VALUES ('548163H29072047247','Javier','Álvarez Alba','71183668S','Calle Quevedo, 2, Piso 7B','true','2017-01-07','aceptada','548163H');
INSERT INTO Solicitud VALUES ('447986M74851257493','Lucia','Casquete Manso','12348672V','Calle Tokio, 13','false','2017-12-12','cancelada','447986M');
INSERT INTO Solicitud VALUES ('330173B47218447982','Pedro','García Pérez','12439680G','Calle Aurora, 89','true','2018-06-15','pendiente','330173B');

INSERT INTO Abono VALUES ('480974988W','false','conreserva');
INSERT INTO Abono VALUES ('509535735J','false','sinreserva-nocturno');
INSERT INTO Abono VALUES ('641292490Y','true','conreserva');
INSERT INTO Abono VALUES ('031544428P','false','cesion');
INSERT INTO Abono VALUES ('282840982C','true','sinreserva-diurno');
