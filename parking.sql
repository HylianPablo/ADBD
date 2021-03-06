--Equipo 0

DROP TABLE IF EXISTS Incidencia;
DROP TABLE IF EXISTS Referencia;
DROP TABLE IF EXISTS Ticket;
DROP TABLE IF EXISTS ContratoAbono;
DROP TABLE IF EXISTS ContratoLaboral;
DROP TABLE IF EXISTS Abono;
DROP TABLE IF EXISTS PlazaRotacional;
DROP TABLE IF EXISTS PlazaResidencial;
DROP TABLE IF EXISTS Solicitud;
DROP TABLE IF EXISTS Valoracion;
DROP TABLE IF EXISTS Trabajador;
DROP TABLE IF EXISTS Vehiculo;
DROP TABLE IF EXISTS Usuario;
DROP TABLE IF EXISTS Persona;
DROP TABLE IF EXISTS Aparcamiento;
DROP TABLE IF EXISTS Globales;


-- CREATE ASSERTION nplazasres(
-- 	-- Las solicitudes sólo pueden tener como objetivo aparcamientos con plazas residenciales.
-- 	CHECK (NOT EXISTS (SELECT *
-- 		FROM Solicitud S NATURAL JOIN Aparcamiento A
-- 		WHERE A.numplazastotales = (
-- 			SELECT COUNT(*) FROM Aparcamiento A NATURAL JOIN PlazaRotacional PRot)))
-- 	);

-- CREATE ASSERTION sinreservanores(
-- 	-- (Un abono de tipo "sin reserva diurno/nocturno" tiene que estar relacionado con 0 plazas residenciales
-- 	-- y los otros tipos con una.)
-- 	-- No pueden existir abonos "sin reserva diurno/nocturno" relacionados con plazas residenciales.
-- 	CHECK (NOT EXISTS (SELECT *
-- 		FROM Abono A NATURAL JOIN PlazaResidencial PRes
-- 		WHERE A.tipo_abono IN ('sinreserva-diurno', 'sinreserva-nocturno')))
-- 	);

-- CREATE ASSERTION reservares(
-- 	-- (Un abono de tipo "sin reserva diurno/nocturno" tiene que estar relacionado con 0 plazas residenciales
-- 	-- y los otros tipos con una.)
-- 	-- No pueden existir abonos 'con reserva' o 'cesión' sin relacionar con una plaza residencial.
-- 	CHECK (NOT EXISTS (SELECT *
-- 		FROM Abono A
-- 		WHERE A.codigoplaza IS NULL AND A.tipo_abono IN ('conreserva', 'cesion')))
-- 	);

-- CREATE ASSERTION tarifasmaximas(
-- 	-- Las tarifas están acotadas superiormente por una tarifa máxima por cada tipo.
-- 	CHECK (EXISTS (SELECT * FROM Globales G
--		WHERE G.tarifamaxauto >= ALL (SELECT A.tarifaautomovil FROM Aparcamiento A) AND
--		G.tarifamaxmoto >= ALL (SELECT A.tarifamotocicleta FROM Aparcamiento A) AND
--		G.tarifamaxcarav >= ALL (SELECT A.tarifaautocaravana FROM Aparcamiento A))
-- 	);
--
-- CREATE ASSERTION plazaresidencialenparking(
--	CHECK (NOT EXISTS( SELECT *
--		FROM Abono Ab NATURAL JOIN PlazaResidencial Pres
--		WHERE Ab.codigoparking<>Pres.codigoparking))
--	);
--
-- CREATE ASSERTION movilidadsosteniblerotacional(
--	CHECK (NOT EXISTS (SELECT *
--		FROM Aparcamiento Ap NATURAL JOIN Abono Ab
--		WHERE Ab.movsostenible=TRUE AND Ab.tipo_abono IN ('sinreserva-diurno', 'sinreserva-nocturno')
--			AND NOT EXISTS (SELECT *
--			FROM Aparcamiento Ap NATURAL JOIN PlazaRotacional Prot
--			WHERE Prot.recargaelectrica=TRUE)))
--	);
--
-- CREATE ASSERTION movilidadsostenibleresidencial(
--	CHECK (NOT EXISTS (SELECT *
--		FROM Abono Ab NATURAL JOIN PlazaResidencial Pres
--		WHERE Ab.movsostenible=TRUE AND Ab.tipo_abono IN ('conreserva', 'cesion')
--			AND Pres.recargaelectrica=FALSE))
--	);
--
-- CREATE ASSERTION solicitudessinacreditar(
--		CHECK (NOT EXISTS (SELECT *
--			FROM Solicitud S WHERE S.documentoacreditativovehiculo=FALSE AND S.estado_solicitud = 'aceptada'
--		))
--	);
--
-- CREATE ASSERTION numplazastotalesok(
-- 	CHECK (NOT EXISTS(SELECT *
-- 		FROM Aparcamiento Ap WHERE Ap.numplazastotales <> (
-- 			(SELECT COUNT(*) FROM PlazaRotacional Prot
-- 	        WHERE Ap.codigoparking=Prot.codigoparking) +
-- 	        (SELECT COUNT(*) FROM PlazaResidencial Pres
-- 	        WHERE Ap.codigoparking = Pres.codigoparking))))
-- 	);


CREATE TABLE Globales(
	tarifamaxauto FLOAT,
	tarifamaxmoto FLOAT,
	tarifamaxcarav FLOAT
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
	areadeinfluencia CHAR(40),
	PRIMARY KEY (codigoparking),
	CHECK (numplazastotales > 0),
	CHECK (NOT (NOT espaciovmubasico AND espaciovmuampliado)),
	CHECK (numplazastotales >= numplazasocupadas)
	-- CHECK (tarifasmaximas)
	);

CREATE TABLE Persona(
	nombre CHAR(20),
	apellidos CHAR(40),
	nif CHAR(9),
	domicilio CHAR(80),
	PRIMARY KEY (nif)
);

CREATE TABLE Usuario(
	nif CHAR(9),
	residente BOOLEAN,
	fianza FLOAT,
	numcuotasnopagadas INTEGER,
	pmr BOOLEAN,
	CHECK (numcuotasnopagadas < 2),
	PRIMARY KEY (nif),
	FOREIGN KEY (nif) REFERENCES Persona(nif)
	);

CREATE TABLE Vehiculo(
	matricula CHAR(10),
	modelo CHAR(30),
	distintivoambiental CHAR(30),
	CHECK (distintivoambiental IN ('CERO','ECO','B','C')),
	tipo_vehiculo CHAR(15),
	CHECK (tipo_vehiculo IN ('automovil','motocicleta','autocaravana')),
	PRIMARY KEY (matricula)
	);

CREATE TABLE Trabajador(
	nif CHAR(9),
	gestor BOOLEAN,
	PRIMARY KEY (nif),
	FOREIGN KEY (nif) REFERENCES Persona(nif)
	);

CREATE TABLE Valoracion(
	codigov CHAR(20),
	codigoparking CHAR(20),
	descripcion CHAR(100),
	PRIMARY KEY (codigov,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking)
	);

CREATE TABLE Solicitud(
	codigosolicitud CHAR(20),
  nif CHAR(9),
	acreditacionresidencia BOOLEAN,
	fecha DATE,
	estado_solicitud CHAR(15),
	documentoacreditativovehiculo BOOLEAN,
	CHECK (estado_solicitud IN ('aceptada','pendiente','cancelada')),
	codigoparking CHAR(20),
	movilidadsostenible BOOLEAN,
	matricula CHAR(10),
	-- CHECK (nplazasres),
	-- CHECK (solicitudessinacreditar),
	PRIMARY KEY  (codigosolicitud),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking),
	FOREIGN KEY (matricula) REFERENCES Vehiculo(matricula),
	FOREIGN KEY (nif) REFERENCES Persona(nif)
	);

CREATE TABLE PlazaResidencial(
	coste FLOAT,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN,
	pmr BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza, codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking)
	);

CREATE TABLE PlazaRotacional(
	disuasorio BOOLEAN,
	codigoplaza CHAR(20),
	recargaelectrica BOOLEAN,
	pmr BOOLEAN,
	deshabilitado BOOLEAN,
	codigoparking CHAR(20),
	PRIMARY KEY (codigoplaza, codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking)
	);

CREATE TABLE Abono(
	numeroabono CHAR(20),
	movsostenible BOOLEAN,
	tipo_abono CHAR(20),
	CHECK (tipo_abono IN ('conreserva','sinreserva-diurno','sinreserva-nocturno','cesion')),
	codigoplaza CHAR(20),
	codigoparking CHAR(20),
	PRIMARY KEY (numeroabono),
	FOREIGN KEY (codigoplaza,codigoparking) REFERENCES PlazaResidencial(codigoplaza,codigoparking),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking)
	-- CHECK (sinreservanores)
	-- CHECK (reservares)
	);

CREATE TABLE ContratoLaboral(
	numcontrato CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	codigoparking CHAR(20),
	nif CHAR(9),
	PRIMARY KEY (numcontrato, codigoparking, nif),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking),
	FOREIGN KEY (nif) REFERENCES Trabajador(nif)
	);

CREATE TABLE ContratoAbono(
	numcontrato CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	numeroabono CHAR(20),
	nif CHAR(9),
	motivo CHAR(30),
	CHECK (motivo IN ('concesion', 'fallecimiento', 'venta-vivienda', 'liquidacion-gananciales', 'perdida-residencia', 'interes-particular', 'cesion-residente', 'renovacion')),
	PRIMARY KEY (numeroabono, nif, numcontrato),
	FOREIGN KEY (numeroabono) REFERENCES Abono(numeroabono),
	FOREIGN KEY (nif) REFERENCES Usuario(nif)
	);

CREATE TABLE Ticket(
	horae TIME,
	matricula CHAR(10),
	fecha DATE,
	codigoparking CHAR(20),
	precio FLOAT,
	horas TIME,
	PRIMARY KEY (horae, matricula, fecha),
	FOREIGN KEY (matricula) REFERENCES Vehiculo(matricula),
	FOREIGN KEY (codigoparking) REFERENCES Aparcamiento(codigoparking)
	);

CREATE TABLE Referencia(
	matricula CHAR(10),
	numeroabono CHAR(20),
	fechainicio DATE,
	fechafin DATE,
	PRIMARY KEY (matricula, numeroabono, fechainicio),
	FOREIGN KEY (matricula) REFERENCES Vehiculo(matricula),
	FOREIGN KEY (numeroabono) REFERENCES Abono(numeroabono)
	);

CREATE TABLE Incidencia(
	nif CHAR(9),
	codigoi CHAR(20),
	descripcion CHAR(200),
	fecha DATE,
	PRIMARY KEY (codigoi),
	FOREIGN KEY (nif) REFERENCES Usuario(nif)
);

INSERT INTO Globales VALUES (1000000000, 1000000000, 1000000000);

INSERT INTO Aparcamiento VALUES ('123456D',4,2,true,true,true,true,2.5,1.2,3,'chamartin');
INSERT INTO Aparcamiento VALUES ('398930Q',2,2,true,true,false,false,2.3,1.1,2.9,'atocha');
INSERT INTO Aparcamiento VALUES ('648509K',4,0,false,true,false,false,2,1,2.5,'plaza mayor');
INSERT INTO Aparcamiento VALUES ('626873M',3,3,false,false,false,false,1.8,0.8,3.4,'puerta del sol');
INSERT INTO Aparcamiento VALUES ('592849H',3,1,true,true,true,false,2.6,1.4,3.2,'cuatro quesos');
INSERT INTO Aparcamiento VALUES ('214749H',3,2,true,true,true,true,2,1.4,3.2,'las ramblas');
INSERT INTO Aparcamiento VALUES ('590348L',3,3,true,true,true,true,1.6,1.4,3.4,'las viudas');
INSERT INTO Aparcamiento VALUES ('111111M',3,0,false,false,false,false,1.8,1.6,2.8,'parquesol');
INSERT INTO Aparcamiento VALUES ('789214R',3,1,true,false,false,false,2.4,1.2,3,'wabu sabi');
INSERT INTO Aparcamiento VALUES ('103647K',3,3,false,false,false,false,2.7,1.6,2.7,'uva');

INSERT INTO Persona VALUES ('Juan','Gatón Díez','71189567Q','Calle Luz, 8');
INSERT INTO Persona VALUES ('Marta','Martín De la Fuente','12438957J','Calle Mango, 34, Piso 2C');
INSERT INTO Persona VALUES ('Javier','Álvarez Alba','71183668S','Calle Quevedo, 2, Piso 7B');
INSERT INTO Persona VALUES ('Lucia','Casquete Manso','12348672V','Calle Tokio, 13');
INSERT INTO Persona VALUES ('Pedro','García Pérez','12439680G','Calle Aurora, 89');
INSERT INTO Persona VALUES ('Marcos','López Pérez','12439681W','Calle Uno, 9');
INSERT INTO Persona VALUES ('Yuri','García Fernandez','12439682K','Calle Dos, 99');
INSERT INTO Persona VALUES ('Carlos','Rojo Ramos','63459680P','Calle Cuatro, 81');
INSERT INTO Persona VALUES ('Lucas','Cabero Franco','12432100G','Calle Tres, 29');
INSERT INTO Persona VALUES ('Victor','Martinez Sanz','00000001A','Calle Cinco, 29');
INSERT INTO Persona VALUES ('Santiago','Ruiz López','00000002B','Calle Seis, 39');
INSERT INTO Persona VALUES ('Pablo','Andrés Kristos','00000003C','Calle Tres, 74');
INSERT INTO Persona VALUES ('Enrique','Lozano Moya','00000004D','Calle Dos, 29');
INSERT INTO Persona VALUES ('Inma','Rodriguez Valdivieso','71188507B','Calle Universitaria, 14, Piso 8B');
INSERT INTO Persona VALUES ('Manuel','Prieto Ruiz','71198567K','Calle Falsa ,123');
INSERT INTO Persona VALUES ('Hugo','Gómez Hernández','12376480L','Calle Farsa, 321');
INSERT INTO Persona VALUES ('Alejandra','Abril Nieto','12453120N','Calle Sueño, 3, Piso 8C');
INSERT INTO Persona VALUES ('Paula','Renero Taboada','12598675D','Calle Falsa , 8');
INSERT INTO Persona VALUES ('Daniela','Romero Villacorta','12890564J','Calle Pizarra, 1, Piso 3A');
INSERT INTO Persona VALUES ('Manuela','Sanz Sánchez','71169374G','Calle Doce, 10');
INSERT INTO Persona VALUES ('Maria','Rosales Iglesias','01235789L','Calle Trece, 11');
INSERT INTO Persona VALUES ('Antonio','Marínez Vazquez','14736925M','Calle Catorce, 14');
INSERT INTO Persona VALUES ('Ana','San Juan Sanz','11223366C','Calle Once, 7, Piso 6B');
INSERT INTO Persona VALUES ('Eduardo','Ruiz Kim','03214789T','Calle Cinco, 88, Piso 5G');
INSERT INTO Persona VALUES ('Alberto','Moya Sanz','44556699N','Calle Cortada, 63, Piso 4F');
INSERT INTO Persona VALUES ('Carlos','Martinez Noé','75855555D','Calle Santa, 7, Piso 3A');
INSERT INTO Persona VALUES ('Oksana','Konstatinidiq Pruk','16748369B','Calle Reyes Magos, 1, Piso 1B');

INSERT INTO Usuario VALUES ('71189567Q',true,100,0,false);
INSERT INTO Usuario VALUES ('12438957J',true,50,0,false);
INSERT INTO Usuario VALUES ('71183668S',true,70,1,false);
INSERT INTO Usuario VALUES ('12348672V',false,80,0,false);
INSERT INTO Usuario VALUES ('12439680G',true,90,1,false);
INSERT INTO Usuario VALUES ('12439681W',true,20,1,false);
INSERT INTO Usuario VALUES ('12439682K',true,10,0,false);
INSERT INTO Usuario VALUES ('63459680P',true,10,1,true);
INSERT INTO Usuario VALUES ('12432100G',false,20,0,false);
INSERT INTO Usuario VALUES ('00000001A',false,60,0,true);
INSERT INTO Usuario VALUES ('00000002B',true,14,0,false);
INSERT INTO Usuario VALUES ('00000003C',true,88,0,false);
INSERT INTO Usuario VALUES ('00000004D',true,13,1,false);
INSERT INTO Usuario VALUES ('71188507B',true,12,0,false);

INSERT INTO Vehiculo VALUES ('7391-FSL','Nissan','C','automovil');
INSERT INTO Vehiculo VALUES ('6794-DXV','Audi','B','automovil');
INSERT INTO Vehiculo VALUES ('0588-GJC','Yamaha','ECO','motocicleta');
INSERT INTO Vehiculo VALUES ('5537-YUP','Ferrari','CERO','automovil');
INSERT INTO Vehiculo VALUES ('2134-FCK','Volvo','C','autocaravana');
INSERT INTO Vehiculo VALUES ('7275-GTB','Seat','B','automovil');
INSERT INTO Vehiculo VALUES ('0420-CFK','Mercedes','ECO','automovil');
INSERT INTO Vehiculo VALUES ('1312-ACA','Challenger','CERO','autocaravana');
INSERT INTO Vehiculo VALUES ('1477-JKR','Carthago','C','autocaravana');
INSERT INTO Vehiculo VALUES ('0001-AAA','Tesla','B','automovil');
INSERT INTO Vehiculo VALUES ('0010-UWU','Vespa','CERO','motocicleta');

INSERT INTO Trabajador VALUES ('71198567K',true);
INSERT INTO Trabajador VALUES ('12376480L',false);
INSERT INTO Trabajador VALUES ('12453120N',false);
INSERT INTO Trabajador VALUES ('12598675D',true);
INSERT INTO Trabajador VALUES ('12890564J',false);
INSERT INTO Trabajador VALUES ('71169374G',false);
INSERT INTO Trabajador VALUES ('01235789L',true);
INSERT INTO Trabajador VALUES ('14736925M',false);
INSERT INTO Trabajador VALUES ('11223366C',false);
INSERT INTO Trabajador VALUES ('03214789T',false);
INSERT INTO Trabajador VALUES ('44556699N',false);
INSERT INTO Trabajador VALUES ('75855555D',false);
INSERT INTO Trabajador VALUES ('16748369B',true);

INSERT INTO Valoracion VALUES ('123456D8753277532','123456D','correcto');
INSERT INTO Valoracion VALUES ('123456D5319274742','123456D','malo');
INSERT INTO Valoracion VALUES ('398930Q3631404429','398930Q','correcto');
INSERT INTO Valoracion VALUES ('648509K8731387119','648509K','perfecto');
INSERT INTO Valoracion VALUES ('626873M3309084705','626873M','pesimo');
INSERT INTO Valoracion VALUES ('214749H1254639870','214749H','alguien aparco en mi plaza');
INSERT INTO Valoracion VALUES ('590348L0000000045','590348L','el bano estaba sucio');
INSERT INTO Valoracion VALUES ('590348L0101010478','590348L','limpien el bano');
INSERT INTO Valoracion VALUES ('111111M0123652586','111111M','buen servicio al cliente');
INSERT INTO Valoracion VALUES ('111111M1114455873','111111M','correcto');
INSERT INTO Valoracion VALUES ('789214R1474587566','789214R','hace frio den la calefaccion');
INSERT INTO Valoracion VALUES ('103647K5555547855','103647K','pesimo');

INSERT INTO Solicitud VALUES ('123456D74841277493','71189567Q',true,'2011-04-14','aceptada',true,'123456D',false);
INSERT INTO Solicitud VALUES ('398930Q77491833085','12438957J',true,'2013-08-24','aceptada',true,'398930Q',false);
INSERT INTO Solicitud VALUES ('626873M29072047247','71183668S',true,'2017-01-07','aceptada',true,'626873M',false);
INSERT INTO Solicitud VALUES ('648509K74851257493','12348672V',false,'2017-12-12','cancelada',false,'648509K',true);
INSERT INTO Solicitud VALUES ('123456D92218447982','12439680G',true,'2018-06-15','pendiente',false,'123456D',false);
INSERT INTO Solicitud VALUES ('626873M10101010145','12439681W',true,'2014-06-15','aceptada',true,'626873M',true);
INSERT INTO Solicitud VALUES ('214749H00000000001','12439682K',true,'2019-06-15','pendiente',false,'214749H',true);
INSERT INTO Solicitud VALUES ('648509K11111111110','63459680P',true,'2018-04-15','cancelada',false,'648509K',false);
INSERT INTO Solicitud VALUES ('123456D45874587463','12432100G',false,'2018-01-05','pendiente',false,'123456D',false);
INSERT INTO Solicitud VALUES ('111111M23789452145','00000001A',false,'2018-04-15','aceptada',true,'111111M',true);
INSERT INTO Solicitud VALUES ('214749H00001141254','00000002B',true,'2017-11-14','cancelada',false,'214749H',false);
INSERT INTO Solicitud VALUES ('626873M44444426658','00000003C',true,'2018-05-13','aceptada',true,'626873M',false);
INSERT INTO Solicitud VALUES ('214749H14526524189','00000004D',true,'2018-01-04','cancelada',false,'214749H',true);
INSERT INTO Solicitud VALUES ('103647K22225447364','71188507B',true,'2019-08-14','aceptada',true,'103647K',false);

INSERT INTO PlazaResidencial VALUES (100, '123456D00198', true, true, true,'123456D');
INSERT INTO PlazaResidencial VALUES (130.4, '398930Q00125', true, true, true,'398930Q');
INSERT INTO PlazaResidencial VALUES (101.6, '648509K00215', false, true, true,'648509K');
INSERT INTO PlazaResidencial VALUES (97.5, '626873M00075', false, false, true,'626873M');
INSERT INTO PlazaResidencial VALUES (140, '592849H00124', false, true, false,'592849H');
INSERT INTO PlazaResidencial VALUES (107.8, '214749H00150', true, true, false,'214749H');
INSERT INTO PlazaResidencial VALUES (100.99, '590348L00095', true, false, true,'590348L');
INSERT INTO PlazaResidencial VALUES (158.98, '111111M00115', true, false, true,'111111M');
INSERT INTO PlazaResidencial VALUES (100.52, '789214R00105', true, false, true,'789214R');
INSERT INTO PlazaResidencial VALUES (179.26, '103647K00097', false, true, false,'103647K');
INSERT INTO PlazaResidencial VALUES (97.5, '626873M00076', false, false, true,'626873M');
INSERT INTO PlazaResidencial VALUES (101.6, '648509K0015', false, true, true,'648509K');
INSERT INTO PlazaResidencial VALUES (100.99, '590348L00014', true, false, true,'590348L');
INSERT INTO PlazaResidencial VALUES (107.8, '214749H00025', true, true, true,'214749H');
INSERT INTO PlazaResidencial VALUES (158.98, '111111M00100', true, false, true,'111111M');
INSERT INTO PlazaResidencial VALUES (179.26, '103647K00014', false, true, false,'103647K');
INSERT INTO PlazaResidencial VALUES (100.52, '789214R00014', true, false, true,'789214R');

INSERT INTO PlazaRotacional VALUES (true, '123456D00155', true, true, false, '123456D');
INSERT INTO PlazaRotacional VALUES (false, '398930Q00085', true, false, false, '398930Q');
INSERT INTO PlazaRotacional VALUES (false, '648509K00001', false, false, false, '648509K');
INSERT INTO PlazaRotacional VALUES (false, '626873M00229', false, false, false, '626873M');
INSERT INTO PlazaRotacional VALUES (false, '123456D00144', false, false, false, '123456D');
INSERT INTO PlazaRotacional VALUES (false, '592849H00120', false, false, true, '592849H');
INSERT INTO PlazaRotacional VALUES (false, '214749H00026', true, false, false, '214749H');
INSERT INTO PlazaRotacional VALUES (true, '590348L00054', false, false, false, '590348L');
INSERT INTO PlazaRotacional VALUES (false, '111111M00095', false, true, false, '111111M');
INSERT INTO PlazaRotacional VALUES (false, '789214R00016', false, false, true, '789214R');
INSERT INTO PlazaRotacional VALUES (false, '103647K00050', false, false, false, '103647K');
INSERT INTO PlazaRotacional VALUES (false, '592849H00099', false, false, false, '592849H');
INSERT INTO PlazaRotacional VALUES (true, '123456D00123', false, false, true, '123456D');
INSERT INTO PlazaRotacional VALUES (false, '648509K00002', false, false, false, '648509K');

INSERT INTO Abono VALUES ('480974988W',false,'conreserva', '123456D00198', '123456D');
INSERT INTO Abono VALUES ('509535735J',false,'sinreserva-nocturno', NULL, '398930Q');
INSERT INTO Abono VALUES ('641292490Y',true,'conreserva', '111111M00115', '111111M');
INSERT INTO Abono VALUES ('031544428P',false,'cesion', '111111M00100', '111111M');
INSERT INTO Abono VALUES ('282840982C',true,'sinreserva-diurno', NULL, '592849H');
INSERT INTO Abono VALUES ('282812342M',false,'sinreserva-diurno', NULL, '214749H');
INSERT INTO Abono VALUES ('567840982A',false,'cesion', '626873M00076', '626873M');
INSERT INTO Abono VALUES ('242834982M',true,'conreserva', '398930Q00125', '398930Q');
INSERT INTO Abono VALUES ('211140980L',false,'cesion', '648509K00215', '648509K');
INSERT INTO Abono VALUES ('012840752S',true,'sinreserva-nocturno', NULL, '103647K');
INSERT INTO Abono VALUES ('281453982V',false,'cesion', '789214R00014', '789214R');
INSERT INTO Abono VALUES ('012815432X',false,'cesion', '103647K00014', '103647K');
INSERT INTO Abono VALUES ('456268510M',false,'conreserva', '103647K00097', '103647K');
INSERT INTO Abono VALUES ('284440756G',false,'sinreserva-diurno', NULL, '214749H');
INSERT INTO Abono VALUES ('175236982B',false,'cesion', '214749H00025', '214749H');
INSERT INTO Abono VALUES ('285678882C',false,'conreserva', '590348L00095', '590348L');

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

INSERT INTO ContratoAbono VALUES ('988W01A658','2014-01-03','2015-12-30','480974988W','00000001A','concesion');
INSERT INTO ContratoAbono VALUES ('735J02B465','2016-01-07','2017-12-30','509535735J','00000002B','concesion');
INSERT INTO ContratoAbono VALUES ('490Y03C357','2014-01-08','2015-12-30','641292490Y','00000003C','concesion');
INSERT INTO ContratoAbono VALUES ('428P04D078','2017-01-10','2018-12-30','031544428P','00000004D','concesion');
INSERT INTO ContratoAbono VALUES ('982C67Q538','2018-01-01','2019-12-30','282840982C','71189567Q','concesion');
INSERT INTO ContratoAbono VALUES ('342M57J001','2014-01-01','2015-12-30','282812342M','12438957J','concesion');
INSERT INTO ContratoAbono VALUES ('982A68S000','2015-02-02','2016-12-30','567840982A','71183668S','concesion');
INSERT INTO ContratoAbono VALUES ('982M80G010','2018-03-03','2019-12-30','242834982M','12439680G','concesion');
INSERT INTO ContratoAbono VALUES ('980L81W011','2016-04-04','2017-12-30','211140980L','12439681W','concesion');
INSERT INTO ContratoAbono VALUES ('752S82K100','2016-05-05','2017-12-30','012840752S','12439682K','fallecimiento');
INSERT INTO ContratoAbono VALUES ('752S82K000','2017-12-30','2018-12-30','012840752S','12439682K','renovacion');
INSERT INTO ContratoAbono VALUES ('982V80P101','2018-06-06','2020-12-30','281453982V','63459680P','concesion');
INSERT INTO ContratoAbono VALUES ('432X00G110','2010-07-07','2011-12-30','012815432X','12432100G','concesion');
INSERT INTO ContratoAbono VALUES ('756G07B002','2011-09-09','2014-12-30','284440756G','71188507B','concesion');

INSERT INTO Ticket VALUES ('18:00','7391-FSL','2019-11-11','123456D',3,'19:00');
INSERT INTO Ticket VALUES ('18:10','6794-DXV','2018-07-05','398930Q',2.3,'20:07');
INSERT INTO Ticket VALUES ('19:00','0588-GJC','2013-04-27','648509K',0.4,'19:30');
INSERT INTO Ticket VALUES ('08:03','5537-YUP','2000-01-12','590348L',8.3,'23:59');
INSERT INTO Ticket VALUES ('01:48','2134-FCK','2010-09-18','103647K',2.4,'18:50');
INSERT INTO Ticket VALUES ('12:48','7275-GTB','2011-02-12','789214R',1.5,'17:50');
INSERT INTO Ticket VALUES ('11:51','0420-CFK','2016-07-12','111111M',2.13,'14:55');
INSERT INTO Ticket VALUES ('10:48','1312-ACA','2016-11-17','590348L',2.45,'12:14');
INSERT INTO Ticket VALUES ('04:20','1477-JKR','2018-01-30','214749H',0.96,'10:24');
INSERT INTO Ticket VALUES ('17:12','0001-AAA','2016-08-10','592849H',0.01,'18:50');
INSERT INTO Ticket VALUES ('14:01','0010-UWU','2018-04-22','214749H',100.02,'15:12');

INSERT INTO Referencia VALUES ('7391-FSL', '480974988W', '2018-12-05', '2020-12-30');
INSERT INTO Referencia VALUES ('6794-DXV', '509535735J', '2016-06-15', '2018-05-30');
INSERT INTO Referencia VALUES ('0588-GJC', '282840982C', '2013-06-12', '2015-12-21');
INSERT INTO Referencia VALUES ('5537-YUP', '282812342M', '2014-02-12', '2016-01-21');
INSERT INTO Referencia VALUES ('2134-FCK', '567840982A', '2016-02-15', '2018-06-14');
INSERT INTO Referencia VALUES ('7275-GTB', '641292490Y', '2018-10-05', '2020-07-24');
INSERT INTO Referencia VALUES ('0420-CFK', '031544428P', '2014-06-03', '2016-12-01');
INSERT INTO Referencia VALUES ('1312-ACA', '242834982M', '2017-05-24', '2018-12-16');
INSERT INTO Referencia VALUES ('1477-JKR', '211140980L', '2016-03-31', '2018-04-01');
INSERT INTO Referencia VALUES ('0001-AAA', '012840752S', '2013-01-12', '2014-06-15');
INSERT INTO Referencia VALUES ('0010-UWU', '281453982V', '2016-09-04', '2018-06-02');

INSERT INTO Incidencia VALUES ('71189567Q','12345L','Golpeo columna','2014-06-15');
INSERT INTO Incidencia VALUES ('12438957J','00000J','Destruyo bano','2014-06-15');
INSERT INTO Incidencia VALUES ('71183668S','00001S','Rompio bano','2014-06-15');
INSERT INTO Incidencia VALUES ('12348672V','00010V','Golpeo columna','2014-06-15');
INSERT INTO Incidencia VALUES ('12439680G','00011G','Golpeo columna','2014-06-15');
INSERT INTO Incidencia VALUES ('63459680P','00100P','Golpeo coche','2014-06-15');
INSERT INTO Incidencia VALUES ('12432100G','00101G','Golpeo columna','2014-06-15');
INSERT INTO Incidencia VALUES ('00000001A','00110A','Golpeo bano','2014-06-15');
INSERT INTO Incidencia VALUES ('00000002B','00111B','Golpeo barrera','2014-06-15');
INSERT INTO Incidencia VALUES ('71188507B','01000B','Mancho bano','2014-06-15');
INSERT INTO Incidencia VALUES ('71183668S','01001S','Golpeo columna','2014-06-15');
INSERT INTO Incidencia VALUES ('00000004D','01010D','Golpeo columna','2014-06-15');


--	%%%%% VISTAS %%%%%
--
--	Esta vista simula una supuesta tabla a la que accede el gestor del aparcamiento.
--	Tiene varios campos restringidos por motivos de privacidad y accede a personas no PMR y residentes:
--	CREATE VIEW VistaGestor(nombre, apellidos, nif) AS
--	SELECT U.nombre, U.apellidos, U.nif, U.pmr
--	FROM Usuario U
--	WHERE U.pmr=FALSE AND U.residente=TRUE
--
--	Esta vista simula una supuesta tabla a la que accede un trabajador (no gestor) del aparcamiento.
--	Tiene varios campos restringidos por motivos de privacidad y
--	accede a personas residentes que tienen todas las cuotas pagadas:
--	CREATE VIEW VistaTrabajador(nombre,apellidos,domicilio) AS
--	SELECT U.nombre, U.apellidos, U.domicilio
--	FROM Usuario U
--	WHERE U.residente=TRUE AND U.numCuotasNoPagadas=0;

--	%%%%% CONSULTAS %%%%%
--
--	Vehículos con clasificación ambiental 'C' que han estado en un parking el '2019-11-11'.
--	SELECT V.matricula, COUNT(*)
--	FROM Ticket T NATURAL JOIN Vehiculo V
--	WHERE V.distAmbiental='C' AND T.fecha='2019-11-11'
--	GROUP BY V.matricula;
--
--	Plazas residenciales con coste superior a 100 que tengan recarga eléctrica.
--	SELECT P.codigoPlaza
--	FROM PlazaResidencial P
--	WHERE P.coste>=100 AND P.recargaElectrica=TRUE;
--
--	Usuarios con abonos sin reserva.
--	SELECT CA.nif
--	FROM ContratoAbono CA NATURAL JOIN Abono A
--	WHERE A.tipo_abono='sinreserva-diurno' OR
--	A.tipo_abono='sinreserva-nocturno';
--
--	Aparcamiento con más plazas.
--	SELECT A.codigoParking
--	FROM Aparcamiento A
--	WHERE A.numPlazasTotales>= ALL(
--		SELECT A2.numPlazasTotales
--		FROM Aparcamiento A2);
