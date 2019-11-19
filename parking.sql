--Equipo 09

DROP TABLE Solicitud;
DROP TABLE Aparcamiento;
DROP TABLE Valoracion;
DROP TABLE Gestor;
DROP TABLE Contrato;
DROP TABLE Abono;
DROP TABLE PlazaResidencial;
DROP TABLE PlazaRotacional;
CREATE TYPE estado_solicitud AS
ENUM('aceptada','pendiente', 'cancelada');
CREATE TYPE tipo_abono AS
ENUM('conreserva', 'sinreserva-diurno', 'sinreserva-nocturno','cesion');

CREATE TABLE Valoracion(codigov CHAR(20),
	codigoparking CHAR(20), 
	descripcion CHAR(100), 
	PRIMARY KEY (codigov,codigoparking), 
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Solicitud(codigosolicitud CHAR(20), 
	nombre CHAR(80), 
       	nif CHAR(9), 
	domicilio CHAR(40), 
	acreditacionresidencia BOOLEAN, 
	fecha DATE, 
	estado estado_solicitud, 
	codigoparking CHAR(20), 
	PRIMARY KEY  (codigosolicitud), 
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE Aparcamiento(codigoparking CHAR(20),
	numplazastotales INTEGER,
       	numplazasocupadas INTEGER, 
	publicidad BOOLEAN, 
	maquinaexpendedora BOOLEAN,
	espaciobicis BOOLEAN,
	espaciovmu BOOLEAN, 
	admisioncomerciante BOOLEAN, 
	tarifavehiculo FLOAT,
	tarifaautocarvana FLOAT,
	tarifabicicleta FLOAT,
	dni CHAR(9), 
	PRIMARY KEY (codigoparking),
	FOREIGN KEY (dni) REFERENCES Gestor);

CREATE TABLE Gestor(nombre CHAR(80), 
	dni CHAR(9), 
	domicilio CHAR(40),
	PRIMARY KEY (dni));

CREATE TABLE Abono(numeroabono CHAR(20), 
	movsostenible BOOLEAN, 
	tipo tipo_abono, 
	PRIMARY KEY (numeroabono));

CREATE TABLE Contrato(fechainicio DATE, 
	fechafin DATE, 
	numeroabono CHAR(20),
	dni CHAR(9),
	PRIMARY KEY (numeroabono, dni),
	FOREIGN KEY (numeroabono) REFERENCES Abono, 
	FOREIGN KEY (dni) REFERENCES Usuario);

CREATE TABLE Usuario(nombre CHAR(80), 
	dni CHAR(9), 
	domicilio CHAR(40),
	residente BOOLEAN, 
	fianza FLOAT, 
	numcuotasnopagadas INTEGER, 
	pmr BOOLEAN,
	PRIMARY KEY (dni));

CREATE TABLE PlazaResidencial(coste FLOAT,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN, 
	personaespecial BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);

CREATE TABLE PlazaRotacional(disuasorio BOOLEAN,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN, 
	personaespecial BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento);
