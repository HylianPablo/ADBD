--Equipo 09

DROP TABLE Solicitud;
DROP TABLE Aparcamiento;
DROP TABLE Valoracion;
DROP TABLE Gestor;
DROP TABLE Contrato;
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

CREATE TABLE Valoracion(
	codigov CHAR(20),
	codigoparking CHAR(20), 
	descripcion CHAR(100), 
	PRIMARY KEY (codigov,codigoparking), 
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Solicitud(
	codigosolicitud CHAR(20), 
	nombre CHAR(80), 
       	nif CHAR(9), 
	domicilio CHAR(40), 
	acreditacionresidencia BOOLEAN, 
	fecha DATE, 
	estado ESTADO_SOLICITUD,
	codigoparking CHAR(20), 
	PRIMARY KEY  (codigosolicitud), 
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Aparcamiento(
	codigoparking CHAR(20),
	numplazastotales INTEGER,
       	numplazasocupadas INTEGER, 
	publicidad BOOLEAN, 
	maquinaexpendedora BOOLEAN,
	espaciobicis BOOLEAN,
	espaciovmu BOOLEAN, 
	admisioncomerciante BOOLEAN, 
	tarifautomovil FLOAT,
	tarifaautocarvana FLOAT,
	tarifamotocicleta FLOAT,
	nif CHAR(9), 
	PRIMARY KEY (codigoparking),
	FOREIGN KEY (nif) REFERENCES Gestor);

CREATE TABLE Gestor(
	nombre CHAR(20), 
	apellidos CHAR(80), 
	nif CHAR(9), 
	domicilio CHAR(40),
	PRIMARY KEY (nif));

CREATE TABLE Abono(
	numeroabono CHAR(20), 
	movsostenible BOOLEAN, 
	tipo TIPO_ABONO, 
	PRIMARY KEY (numeroabono));

CREATE TABLE Contrato(
	fechainicio DATE, 
	fechafin DATE, 
	numeroabono CHAR(20),
	nif CHAR(9),
	PRIMARY KEY (numeroabono, nif),
	FOREIGN KEY (numeroabono) REFERENCES Abono, 
	FOREIGN KEY (nif) REFERENCES Usuario);

CREATE TABLE Gestor(nombre CHAR(80), 
	nif CHAR(9), 
	domicilio CHAR(40),
	PRIMARY KEY (dni));

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


