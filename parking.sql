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

INSERT INTO Solicitud VALUES ('123456D74841277493','Juan','González Díez','71189567Q','Calle Luz, 8','true','2011-04-14','aceptada','123456D');
INSERT INTO Solicitud VALUES ('398930Q77491833085','Marta','Martín De la Fuente','12438957J','Calle Mango, 34, Piso 2C','true','2013-08-24','aceptada','398930Q');
INSERT INTO Solicitud VALUES ('626873M29072047247','Javier','Álvarez Alba','71183668S','Calle Quevedo, 2, Piso 7B','true','2017-01-07','aceptada','626873M');
INSERT INTO Solicitud VALUES ('648509K74851257493','Lucia','Casquete Manso','12348672V','Calle Tokio, 13','false','2017-12-12','cancelada','648509K');
INSERT INTO Solicitud VALUES ('123456D47218447982','Pedro','García Pérez','12439680G','Calle Aurora, 89','true','2018-06-15','pendiente','123456D');

INSERT INTO Abono VALUES ('480974988W','false','conreserva');
INSERT INTO Abono VALUES ('509535735J','false','sinreserva-nocturno');
INSERT INTO Abono VALUES ('641292490Y','true','conreserva');
INSERT INTO Abono VALUES ('031544428P','false','cesion');
INSERT INTO Abono VALUES ('282840982C','true','sinreserva-diurno');

INSERT INTO Aparcamiento VALUES ('123456D','200','80','true','true','true','2.5','1.2','3');
INSERT INTO Aparcamiento VALUES ('398930Q','200','90','true','true','false','2.3','1.1','2.9');
INSERT INTO Aparcamiento VALUES ('648509K','230','80','false','true','false','2','1','2.5');
INSERT INTO Aparcamiento VALUES ('626873M','100','70','false','false','false','1.8','0.8','3.4');
INSERT INTO Aparcamiento VALUES ('592849H','300','190','true','true','true','2.6','1.4','3.2');

INSERT INTO Trabajador VALUES ('Manuel','Prieto Ruiz','71198567K','Calle Falsa ,123','true');
INSERT INTO Trabajador VALUES ('Hugo','Gómez Hernández','12376480L','Calle Farsa, 321','false');
INSERT INTO Trabajador VALUES ('Alejandra','Abril Nieto','12453120N','Calle Sueño, 3, Piso 8C','false');
INSERT INTO Trabajador VALUES ('Paula','Renero Taboada','12598675D','Calle Falsa , 8','true');
INSERT INTO Trabajador VALUES ('Daniela','Romero Villacorta','12890564J','Calle Pizarra, 1, Piso 3A','false');

INSERT INTO ContratoLaboral VALUES ('123456D67K321','2017-01-03','2019-01-03','123456D','71198567K');
INSERT INTO ContratoLaboral VALUES ('398930Q80L768','2016-03-18','2018-02-28','398930Q','12376480L');
INSERT INTO ContratoLaboral VALUES ('648509K20N045','2014-10-04','2017-01-03','648509K','12453120N');
INSERT INTO ContratoLaboral VALUES ('123456D64J856','2018-12-12','2019-02-12','123456D','12890564J');
INSERT INTO ContratoLaboral VALUES ('592849H75D341','2017-01-03','2019-01-03','592849H','12598675D');

INSERT INTO ContratoAbono VALUES ('988W___658','2014-01-03','2015-12-30','480974988W','_________');
INSERT INTO ContratoAbono VALUES ('735J___465','2016-01-07','2017-12-30','509535735J','_________');
INSERT INTO ContratoAbono VALUES ('490Y___357','2014-01-08','2015-12-30','641292490Y','_________');
INSERT INTO ContratoAbono VALUES ('428P___078','2017-01-10','2018-12-30','031544428P','_________');
INSERT INTO ContratoAbono VALUES ('982C___538','2018-01-01','2019-12-30','282840982C','_________');

