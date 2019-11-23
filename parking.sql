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


