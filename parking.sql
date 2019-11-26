--Equipo 0

DROP TABLE IF EXISTS Solicitud;
DROP TABLE IF EXISTS Aparcamiento;
DROP TABLE IF EXISTS Valoracion;
DROP TABLE IF EXISTS Trabajdor;
DROP TABLE IF EXISTS ContratoAbono;
DROP TABLE IF EXISTS ContratoLaboral;
DROP TABLE IF EXISTS Abono;
DROP TABLE IF EXISTS PlazaResidencial;
DROP TABLE IF EXISTS PlazaRotacional;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS Vehiculo;
DROP TABLE IF EXISTS Referencia;

CREATE ASSERTION nplazasres(
	-- Las solicitudes sólo pueden tener como objetivo aparcamientos con plazas residenciales.
	CHECK (NOT EXISTS (SELECT *
		FROM Solicitud S NATURAL JOIN Aparcamiento A
		WHERE A.numplazastotales = (
			SELECT COUNT(*) FROM Aparcamiento A NATURAL JOIN PlazaRotacional PRot)))
	);

CREATE ASSERTION sinreservanores(
	-- (Un abono de tipo "sin reserva diurno/nocturno" tiene que estar relacionado con 0 plazas residenciales
	-- y los otros tipos con una.)
	-- No pueden existir abonos "sin reserva diurno/nocturno" relacionados con plazas residenciales.
	CHECK (NOT EXISTS (SELECT *
		FROM Abono A NATURAL JOIN PlazaResidencial PRes
		WHERE A.tipo_abono IN ('sinreserva-diurno', 'sinreserva-nocturno')))
	);

CREATE ASSERTION reservares(
	-- (Un abono de tipo "sin reserva diurno/nocturno" tiene que estar relacionado con 0 plazas residenciales
	-- y los otros tipos con una.)
	-- No pueden existir abonos 'con reserva' o 'cesión' sin relacionar con una plaza residencial.
	CHECK (NOT EXISTS (SELECT *
		FROM Abono A
		WHERE A.codigoplaza IS NULL AND A.tipo_abono IN ('conreserva', 'cesion')))
	);

CREATE ASSERTION tarifasmaximas(
	-- Las tarifas están acotadas superiormente por una tarifa máxima por cada tipo.
	CHECK ( (SELECT G.tarifamaxauto FROM Globales G) >= ALL (SELECT A.tarifaautomovil FROM Aparcamiento A)),
	CHECK ( (SELECT G.tarifamaxmoto FROM Globales G) >= ALL (SELECT A.tarifamotocicleta FROM Aparcamiento A)),
	CHECK ( (SELECT G.tarifamaxcarav FROM Globales G) >= ALL (SELECT A.tarifaautocaravana FROM Aparcamiento A))
	);

CREATE TABLE Globales(
	tarifamaxauto FLOAT,
	tarifamaxmoto FLOAT,
	tarifacarav FLOAT
	);

CREATE TABLE Valoracion(
	codigov CHAR(20),
	codigoparking CHAR(20),
	descripcion CHAR(100),
	PRIMARY KEY (codigov,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento
	);

CREATE TABLE Solicitud(
	codigosolicitud CHAR(20),
	nombre CHAR(20),
	apellidos CHAR(80),
       	nif CHAR(9),
	domicilio CHAR(40),
	acreditacionresidencia BOOLEAN,
	fecha DATE,
	estado_solicitud CHAR(15),
	CHECK (estado_solicitud IN ('aceptada','pendiente','cancelada')),
	codigoparking CHAR(20),
	CHECK (nplazasres),
	PRIMARY KEY  (codigosolicitud),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento,
	FOREIGN KEY (nombre) REFERENCES Usuario,
	FOREIGN KEY (apellidos) REFERENCES Usuario,
	FOREIGN KEY (nif) REFERENCES Usuario,
	FOREIGN KEY (domicilio) REFERENCES Usuario
	);

CREATE TABLE Aparcamiento(
	codigoparking CHAR(20),
	numplazastotales INTEGER,
       	numplazasocupadas INTEGER,
	espaciobicis BOOLEAN,
	espaciovmubasico BOOLEAN,
	espaciovmuampliado BOOLEAN,
	admisioncomerciante BOOLEAN,
	tarifaautomovil FLOAT,
	tarifaautocaravana FLOAT,
	tarifamotocicleta FLOAT,
	PRIMARY KEY (codigoparking),
	CHECK (numplazastotales > 0),
	CHECK (NOT (NOT espaciovmubasico AND espaciovmuampliado)),
	CHECK (tarifasmaximas)
	);

CREATE TABLE Trabajador(
	nombre CHAR(20),
	apellidos CHAR(80),
	nif CHAR(9),
	domicilio CHAR(40),
	gestor BOOLEAN,
	PRIMARY KEY (nif)
	);

CREATE TABLE Abono(
	numeroabono CHAR(20),
	movsostenible BOOLEAN,
	tipo_abono CHAR(15),
	CHECK (tipo_abono IN ('conreserva','sinreserva-diurno','sinreserva-nocturno','cesion')),
	codigoplaza CHAR(20),
	codigoparking CHAR(20),
	PRIMARY KEY (numeroabono)
	FOREIGN KEY (codigoplaza) REFERENCES PlazaResidencial
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento
	CHECK (sinreservanores)
	CHECK (reservares)
	);

CREATE TABLE ContratoLaboral(
	numcontrato CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	codigoparking CHAR(20),
	nif CHAR(9),
	PRIMARY KEY (numcontrato,numeroparking,nif,numcontrato),
	FOREIGN KEY (numeroparking) REFERENCES Abono,
	FOREIGN KEY (nif) REFERENCES Usuario
	);

CREATE TABLE ContratoAbono(
	numcontrato CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	numeroabono CHAR(20),
	nif CHAR(9),
	PRIMARY KEY (numeroabono, nif,numcontrato),
	FOREIGN KEY (numeroabono) REFERENCES Abono,
	FOREIGN KEY (nif) REFERENCES Usuario
	);

CREATE TABLE Usuario(
	nombre CHAR(20),
	apellidos CHAR(80),
	nif CHAR(9),
	domicilio CHAR(40),
	residente BOOLEAN,
	fianza FLOAT,
	numcuotasnopagadas INTEGER,
	pmr BOOLEAN,
	PRIMARY KEY (nif)
	);

CREATE TABLE PlazaResidencial(
	coste FLOAT,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN,
	personaespecial BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza, codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento
	);

CREATE TABLE PlazaRotacional(
	disuasorio BOOLEAN,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN,
	personaespecial BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza, codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento
	);

CREATE TABLE Ticket(
	horae TIME,
	matricula CHAR(10),
	fecha DATE,
	codiogparking CHAR(20),
	precio FLOAT,
	horas TIME,
	PRIMARY KEY (horae, matricula, fecha),
	FOREIGN KEY (matricula) REFERENCES Vehiculo,
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento
	);

CREATE TABLE Vehiculo(
	matricula CHAR(10),
	modelo CHAR(30),
	acreditacion BOOLEAN,
	distintivoambiental CHAR(30),
	CHECK (distintivo ambiental IN ('CERO','ECO','B','C')),
	tipo_vehiculo CHAR(15),
	CHECK (tipo_vehiculo IN ('automovil','motocicleta','autocaravana')),
	PRIMARY KEY (matricula)
	);

CREATE TABLE Referencia(
	matricula CHAR(10),
	numeroabono CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	PRIMARY KEY (matricula, numeroabono),
	FOREIGN KEY (matricula) REFERENCES Vehiculo,
	FOREIGN KEY (numeroabono) REFERENCES Abono
	);



INSERT INTO Valoracion VALUES ('123456D8753277532','123456D','correcto');
INSERT INTO Valoracion VALUES ('123456D5319274742','123456D','malo');
INSERT INTO Valoracion VALUES ('398930Q3631404429','398930Q','correcto');
INSERT INTO Valoracion VALUES ('648509K8731387119','648509K','perfecto');
INSERT INTO Valoracion VALUES ('626873M3309084705','626873M','pesimo');
INSERT INTO Valoracion VALUES ('245623K0485692147','147852H','correcto');
INSERT INTO Valoracion VALUES ('214749H1254639870','214749H','alguien aparco en mi plaza');
INSERT INTO Valoracion VALUES ('590348L0000000045','590348L','el bano estaba sucio');
INSERT INTO Valoracion VALUES ('590348L0101010478','590348L','limpien el bano');
INSERT INTO Valoracion VALUES ('111111M0123652586','111111M','buen servicio al cliente');
INSERT INTO Valoracion VALUES ('111111M1114455873','111111M','correcto');
INSERT INTO Valoracion VALUES ('789214R1474587566','789214R','hace frio den la calefaccion');
INSERT INTO Valoracion VALUES ('103647K5555547855','103647K','pesimo');

INSERT INTO Solicitud VALUES ('123456D74841277493','Juan','González Díez','71189567Q','Calle Luz, 8','true','2011-04-14','aceptada','123456D');
INSERT INTO Solicitud VALUES ('398930Q77491833085','Marta','Martín De la Fuente','12438957J','Calle Mango, 34, Piso 2C','true','2013-08-24','aceptada','398930Q');
INSERT INTO Solicitud VALUES ('626873M29072047247','Javier','Álvarez Alba','71183668S','Calle Quevedo, 2, Piso 7B','true','2017-01-07','aceptada','626873M');
INSERT INTO Solicitud VALUES ('648509K74851257493','Lucia','Casquete Manso','12348672V','Calle Tokio, 13','false','2017-12-12','cancelada','648509K');
INSERT INTO Solicitud VALUES ('123456D92218447982','Pedro','García Pérez','12439680G','Calle Aurora, 89','true','2018-06-15','pendiente','123456D');
INSERT INTO Solicitud VALUES ('626873M10101010145','Marcos','López Pérez','12439681W','Calle Uno, 9','true','2014-06-15','aceptada','626873M');
INSERT INTO Solicitud VALUES ('214749H00000000001','Yuri','García Fernandez','12439682K','Calle Dos, 99','true','2019-06-15','pendiente','214749H');
INSERT INTO Solicitud VALUES ('648509K11111111110','Carlos','Rojo Ramos','63459680P','Calle Cuatro, 81','true','2018-04-15','cancelada','648509K');
INSERT INTO Solicitud VALUES ('123456D45874587463','Lucas','Cabero Franco','12432100G','Calle Tres, 29','false','2018-01-05','pendiente','123456D');
INSERT INTO Solicitud VALUES ('111111M23789452145','Victor','Martinez Sanz','','Calle Cinco, 29','false','2018-04-15','aceptada','111111M');
INSERT INTO Solicitud VALUES ('214749H00001141254','Santiago','Ruiz López','','Calle Seis, 39','true','2017-11-14','cancelada','214749H');
INSERT INTO Solicitud VALUES ('626873M44444426658','Pablo','Andrés Kristos','','Calle Tres, 74','true','2018-05-13','aceptada','626873M');
INSERT INTO Solicitud VALUES ('214749H14526524189','Enrique','Lozano Moya','','Calle Dos, 29','true','2018-01-04','cancelada','214749H');
INSERT INTO Solicitud VALUES ('103647K22225447364','Inma','Rodriguez Valdivieso','71188507B','Calle Universitaria, 14, Piso 8B','true','2019-08-14','acepatada','103647K');

INSERT INTO Abono VALUES ('480974988W','false','conreserva', '_________', '123456D');
INSERT INTO Abono VALUES ('509535735J','false','sinreserva-nocturno', '_________', '398930Q');
INSERT INTO Abono VALUES ('641292490Y','true','conreserva', '_________', '648509K');
INSERT INTO Abono VALUES ('031544428P','false','cesion', '_________', '626873M');
INSERT INTO Abono VALUES ('282840982C','true','sinreserva-diurno', '_________', '592849H');
INSERT INTO Abono VALUES ('282812342M','false','sinreserva-diurno', '_________', '214749H');
INSERT INTO Abono VALUES ('567840982A','false','cesion', '_________', '590348L');
INSERT INTO Abono VALUES ('242834982M','true','conreserva', '_________', '111111M');
INSERT INTO Abono VALUES ('211140980L','false','cesion', '_________', '789214R');
INSERT INTO Abono VALUES ('012840752S','true','sinreserva-nocturno', '_________', '103647K');
INSERT INTO Abono VALUES ('281453982V','false','cesion', '_________', '789214R');
INSERT INTO Abono VALUES ('012815432X','false','cesion', '_________', '111111M');
INSERT INTO Abono VALUES ('456268510M','false','conreserva', '_________', '590348L');
INSERT INTO Abono VALUES ('284440756G','false','sinreserva-diurno', '_________', '214749H');
INSERT INTO Abono VALUES ('175236982B','false','cesion', '_________', '592849H');
INSERT INTO Abono VALUES ('285678882C','false','conreserva', '_________', '626873M');

INSERT INTO Aparcamiento VALUES ('123456D','200','80','true','true','true','true','2.5','1.2','3');
INSERT INTO Aparcamiento VALUES ('398930Q','200','90','true','true','false','false','2.3','1.1','2.9');
INSERT INTO Aparcamiento VALUES ('648509K','230','80','false','true','false','false','2','1','2.5');
INSERT INTO Aparcamiento VALUES ('626873M','100','70','false','false','false','false','1.8','0.8','3.4');
INSERT INTO Aparcamiento VALUES ('592849H','300','190','true','true','true','false','2.6','1.4','3.2');
INSERT INTO Aparcamiento VALUES ('214749H','300','186','true','true','true','true','2','1.4','3.2');
INSERT INTO Aparcamiento VALUES ('590348L','100','53','true','true','true','true','1.6','1.4','3.4');
INSERT INTO Aparcamiento VALUES ('111111M','210','150','false','false','false','false','1.8','1.6','2.8');
INSERT INTO Aparcamiento VALUES ('789214R','125','63','true','false','false','false','2.4','1.2','3');
INSERT INTO Aparcamiento VALUES ('103647K','238','162','false','false','false','false','2.7','1.6','2.7');

INSERT INTO Trabajador VALUES ('Manuel','Prieto Ruiz','71198567K','Calle Falsa ,123','true');
INSERT INTO Trabajador VALUES ('Hugo','Gómez Hernández','12376480L','Calle Farsa, 321','false');
INSERT INTO Trabajador VALUES ('Alejandra','Abril Nieto','12453120N','Calle Sueño, 3, Piso 8C','false');
INSERT INTO Trabajador VALUES ('Paula','Renero Taboada','12598675D','Calle Falsa , 8','true');
INSERT INTO Trabajador VALUES ('Daniela','Romero Villacorta','12890564J','Calle Pizarra, 1, Piso 3A','false');
INSERT INTO Trabajador VALUES ('Manuela','Sanz Sánchez','71169374G','Calle Doce, 10','false');
INSERT INTO Trabajador VALUES ('Maria','Rosales Iglesias','01235789L','Calle Trece, 11','true');
INSERT INTO Trabajador VALUES ('Antonio','Marínez Vazquez','14736925M','Calle Catorce, 14','false');
INSERT INTO Trabajador VALUES ('Ana','San Juan Sanz','11223366C','Calle Once, 7, Piso 6B','false');
INSERT INTO Trabajador VALUES ('Eduardo','Ruiz Kim','03214789T','Calle Cinco, 88, Piso 5G','false');
INSERT INTO Trabajador VALUES ('Alberto','Moya Sanz','44556699N','Calle Cortada, 63, Piso 4F','false');
INSERT INTO Trabajador VALUES ('Carlos','Martinez Noé','75855555D','Calle Santa, 7, Piso 3A','false');
INSERT INTO Trabajador VALUES ('Oksana','Konstatinidiq Pruk','16748369B','Calle Reyes Magos, 1, Piso 1B','true');

INSERT INTO ContratoLaboral VALUES ('123456D67K321','2017-01-03','2019-01-03','123456D','71198567K');
INSERT INTO ContratoLaboral VALUES ('398930Q80L768','2016-03-18','2018-02-28','398930Q','12376480L');
INSERT INTO ContratoLaboral VALUES ('648509K20N045','2014-10-04','2017-01-03','648509K','12453120N');
INSERT INTO ContratoLaboral VALUES ('123456D64J856','2018-12-12','2019-02-12','123456D','12890564J');
INSERT INTO ContratoLaboral VALUES ('592849H75D341','2017-01-03','2019-01-03','592849H','12598675D');
INSERT INTO ContratoLaboral VALUES ('789214R74G101','2016-11-14','2018-02-03','789214R','71169374G');
INSERT INTO ContratoLaboral VALUES ('592849H89L000','2014-01-14','2017-12-13','592849H','01235789L');
INSERT INTO ContratoLaboral VALUES ('111111M25M001','2018-03-08','2020-03-23','111111M','14736925M');
INSERT INTO ContratoLaboral VALUES ('214749H66C010','2011-04-04','2017-07-04','214749H','11223366C');
INSERT INTO ContratoLaboral VALUES ('592849H89T011','2014-03-24','2019-09-07','592849H','03214789T');
INSERT INTO ContratoLaboral VALUES ('103647K99N100','2013-10-30','2016-04-06','103647K','44556699N');
INSERT INTO ContratoLaboral VALUES ('648509K55D110','2012-09-12','2015-05-14','648509K','75855555D');
INSERT INTO ContratoLaboral VALUES ('592849H69B111','2011-10-05','2013-03-06','592849H','16748369B');

INSERT INTO ContratoAbono VALUES ('988W___658','2014-01-03','2015-12-30','480974988W','_________');
INSERT INTO ContratoAbono VALUES ('735J___465','2016-01-07','2017-12-30','509535735J','_________');
INSERT INTO ContratoAbono VALUES ('490Y___357','2014-01-08','2015-12-30','641292490Y','_________');
INSERT INTO ContratoAbono VALUES ('428P___078','2017-01-10','2018-12-30','031544428P','_________');
INSERT INTO ContratoAbono VALUES ('982C___538','2018-01-01','2019-12-30','282840982C','_________');
INSERT INTO ContratoAbono VALUES ('342M___001','2014-01-01','2015-12-30','282812342M','_________');
INSERT INTO ContratoAbono VALUES ('982A___000','2015-02-02','2016-12-30','567840982A','_________');
INSERT INTO ContratoAbono VALUES ('982M___010','2018-03-03','2019-12-30','242834982M','_________');
INSERT INTO ContratoAbono VALUES ('980L___011','2016-04-04','2017-12-30','211140980L','_________');
INSERT INTO ContratoAbono VALUES ('752S___100','2016-05-05','2018-12-30','012840752S','_________');
INSERT INTO ContratoAbono VALUES ('982V___101','2018-06-06','2020-12-30','281453982V','_________');
INSERT INTO ContratoAbono VALUES ('432X___110','2010-07-07','2011-12-30','012815432X','_________');
INSERT INTO ContratoAbono VALUES ('510M___111','2018-08-08','2020-12-30','456268510M','_________');
INSERT INTO ContratoAbono VALUES ('756G___002','2011-09-09','2014-12-30','284440756G','_________');
INSERT INTO ContratoAbono VALUES ('982B___020','2018-10-10','2020-12-30','175236982B','_________');
INSERT INTO ContratoAbono VALUES ('882C___022','2011-11-11','2014-12-30','285678882C','_________');

INSERT INTO Ticket VALUES ('18:00','7391-FSL','2019-11-11','123456D','3','19:00');
INSERT INTO Ticket VALUES ('18:10','6794-DXV','2018-07-05','398930Q','2.3','20:07');
INSERT INTO Ticket VALUES ('19:00','0588-GJC','2013-04-27','648509K','0.4','19:30');
INSERT INTO Ticket VALUES ('08:03','5537-YUP','2000-01-12','590348L','8.3','23:59');
INSERT INTO Ticket VALUES ('01:48','2134-FCK','2010-09-18','103647K','2','18:50');

INSERT INTO Vehiculo VALUES ('7391-FSL','Nissan','true','C','automovil');
INSERT INTO Vehiculo VALUES ('6794-DXV','Audi','true','B','automovil');
INSERT INTO Vehiculo VALUES ('0588-GJC','Yamaha','true','ECO','motocicleta');
INSERT INTO Vehiculo VALUES ('5537-YUP','Ferrari','true','CERO','automovil');
INSERT INTO Vehiculo VALUES ('2134-FCK','Volvo','true','C','autocaravana');
