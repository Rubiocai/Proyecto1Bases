
CREATE TABLE Species(
	ID INT NOT NULL,
	SCIENCE_NAME VARCHAR(100) NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Common_Names(
	ID INT NOT NULL,
	ID_SP INT,
	COM_NAME VARCHAR(100),
	PRIMARY KEY(ID),
	FOREIGN KEY(ID_SP) REFERENCES Species(ID)
);

CREATE TABLE Collection(
	ID INT NOT NULL,
	NAME_COLLEC VARCHAR(100) NOT NULL,
	DESCRIPTION VARCHAR(450) NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Author(
	ID INT NOT NULL,
	CED INT NOT NULL,
	FIRST_NAME VARCHAR(70) NOT NULL,
	SECOND_NAME VARCHAR(70) NOT NULL,
	FIRST_LAST_NAME VARCHAR(100) NOT NULL,
	SECOND_LAST_NAME VARCHAR(100) NOT NULL,
	TELEPHONE_NUM INT NOT NULL,
	MAIL VARCHAR(100) NOT NULL,
	COUNTRY VARCHAR(100) NOT NULL,
	ADDRESS VARCHAR(250) NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Institution(
	ID INT NOT NULL,
	NAME_INSTI VARCHAR(150) NOT NULL,
	PRIMARY KEY(ID)
);

CREATE TABLE Publication_(
	ID INT NOT NULL,
	TITLE VARCHAR(100) NOT NULL,
	PUBLI_DATE DATE NOT NULL,
	EDITORIAL VARCHAR(150) NOT NULL,
	DOI VARCHAR(75) NOT NULL,
	ISBN INT NOT NULL,
	PUBLI_COUNTRY VARCHAR(100) NOT NULL,
	INSTI_ID INT,
	PRIMARY KEY(ID),
	FOREIGN KEY(INSTI_ID) REFERENCES Institution(ID)
);

CREATE TABLE Publi_Collec(
	PUBLI_ID INT,
	COLLEC_ID INT,
	FOREIGN KEY(PUBLI_ID) REFERENCES Publication_(ID),
	FOREIGN KEY(COLLEC_ID) REFERENCES Collection(ID)
);

CREATE TABLE Publi_Author(
	PUBLI_ID INT,
	AUTHOR_ID INT,
	FOREIGN KEY(PUBLI_ID) REFERENCES Publication_(ID),
	FOREIGN KEY(AUTHOR_ID) REFERENCES Author(ID)
);

CREATE TABLE Publi_Species(
	PUBLI_ID INT,
	SPECIE_ID INT,
	FOREIGN KEY(PUBLI_ID) REFERENCES Publication_(ID),
	FOREIGN KEY(SPECIE_ID) REFERENCES Species(ID)
);

CREATE OR REPLACE PROCEDURE Publi_Create(_ID INT, _TITLE VARCHAR(100), _PUBLI_DATE DATE,
    									 _EDITORIAL VARCHAR(150),_DOI VARCHAR(75), _ISBN INT, 
   										 _PUBLI_COUNTRY VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Publication_ (ID, TITLE, PUBLI_DATE, EDITORIAL, DOI, ISBN, PUBLI_COUNTRY)
    VALUES (_ID, _TITLE, _PUBLI_DATE, _EDITORIAL, _DOI, _ISBN, _PUBLI_COUNTRY);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Ya existe una publicación con el ID %.', _ID;
    WHEN OTHERS THEN
        RAISE NOTICE 'Ha ocurrido un error al intentar insertar la publicación.';
END;
$$

--

CREATE OR REPLACE PROCEDURE Conect_Insti_Publi(_ID_PUBLI INT, _ID_INSTI INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Institution WHERE ID = _ID_INSTI) THEN
        RAISE EXCEPTION 'No existe institución con el ID %', _ID_INSTI;
    END IF;
    UPDATE Publication_ SET INSTI_ID = _ID_INSTI WHERE ID = _ID_PUBLI;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Ha ocurrido un error inesperado.';
END;
$$


--

CREATE OR REPLACE PROCEDURE Conect_Collec_Publi(_ID_PUBLI INT, _ID_COLLEC INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
        RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Collection WHERE ID = _ID_COLLEC) THEN
        RAISE EXCEPTION 'No existe colección con el ID %', _ID_COLLEC;
    END IF;
    INSERT INTO Publi_Collec (PUBLI_ID, COLLEC_ID)
    VALUES (_ID_PUBLI, _ID_COLLEC);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'La relación ya existe en Publi_Collec para PUBLI_ID % y COLLEC_ID %', _ID_PUBLI, _ID_COLLEC;
    WHEN OTHERS THEN
        RAISE NOTICE 'Ha ocurrido un error inesperado.';
END;
$$

--

CREATE OR REPLACE PROCEDURE Conect_Author_Publi(_ID_PUBLI INT, _ID_AUTHOR INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
        RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Author WHERE ID = _ID_AUTHOR) THEN
        RAISE EXCEPTION 'No existe autor con el ID %', _ID_AUTHOR;
    END IF;
    INSERT INTO Publi_Author (PUBLI_ID, AUTHOR_ID)
    VALUES (_ID_PUBLI, _ID_AUTHOR);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'La relación ya existe en Publi_Author para PUBLI_ID % y AUTHOR_ID %', _ID_PUBLI, _ID_AUTHOR;
    WHEN OTHERS THEN
        RAISE NOTICE 'Ha ocurrido un error inesperado.';
END;
$$

--

CREATE OR REPLACE PROCEDURE Conect_Species_Publi(_ID_PUBLI INT, _ID_SPECIE INT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
        RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM Species WHERE ID = _ID_SPECIE) THEN
        RAISE EXCEPTION 'No existe especie con el ID %', _ID_SPECIE;
    END IF;
    INSERT INTO Publi_Species (PUBLI_ID, SPECIE_ID)
    VALUES (_ID_PUBLI, _ID_SPECIE);

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'La relación ya existe en Publi_Species para PUBLI_ID % y SPECIE_ID %', _ID_PUBLI, _ID_SPECIE;
    WHEN OTHERS THEN
        RAISE NOTICE 'Ha ocurrido un error inesperado.';
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Update_Title(_ID_PUBLI INT, _TITLE VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	UPDATE Publication_
	SET TITLE = _TITLE
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Update_Date(_ID_PUBLI INT, _PUBLI_DATE DATE)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	UPDATE Publication_
	SET PUBLI_DATE = _PUBLI_DATE
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Update_Editorial(_ID_PUBLI INT, _EDITORIAL VARCHAR(150))
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	UPDATE Publication_
	SET EDITORIAL = _EDITORIAL
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Update_Doi(_ID_PUBLI INT, _DOI VARCHAR(75))
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	UPDATE Publication_
	SET DOI = _DOI
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Update_ISBN(_ID_PUBLI INT, _ISBN INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	UPDATE Publication_
	SET ISBN = _ISBN
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Update_Country(_ID_PUBLI INT, _PUBLI_COUNTRY VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	UPDATE Publication_
	SET PUBLI_COUNTRY = _PUBLI_COUNTRY
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE PROCEDURE Publi_Delete(_ID_PUBLI INT)
LANGUAGE plpgsql
AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Publication_ WHERE ID = _ID_PUBLI) THEN
		RAISE EXCEPTION 'No existe publicación con el ID %', _ID_PUBLI;
	END IF;
	DELETE FROM Publication_
	WHERE ID = _ID_PUBLI;
END;
$$

--

CREATE OR REPLACE FUNCTION Publi_Mostrar(_ID_PUBLI INT)
RETURNS TABLE(ID INT, TITLE VARCHAR(100), PUBLI_DATE DATE,
    EDITORIAL VARCHAR(150), DOI VARCHAR(75),ISBN INT,
    PUBLI_COUNTRY VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT ID, TITLE, PUBLI_DATE, EDITORIAL, DOI, ISBN, PUBLI_COUNTRY
	FROM Publication_
	WHERE Publication_.ID = _ID_PUBLI;
END;
$$

CREATE OR REPLACE FUNCTION Busca_NomSci(_NOM_SCI VARCHAR(100))
RETURNS TABLE(TITLE VARCHAR(100),SCIENCE_NAME VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT Publication_.TITLE, Species.SCIENCE_NAME
	FROM Publication_, Species, Publi_Species
	WHERE Species.SCIENCE_NAME = _NOM_SCI AND
	Species.ID = Publi_Species.SPECIE_ID AND
	Publication_.ID = Publi_Species.PUBLI_ID;
END;
$$

CREATE OR REPLACE FUNCTION Muestra_Collec()
RETURNS TABLE(NAME_COLLEC VARCHAR(100),DESCRIPTION VARCHAR(450))
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT Collection.NAME_COLLEC, Collection.DESCRIPTION
	FROM Collection;
END;
$$

SELECT * FROM Muestra_Collec();

CREATE OR REPLACE FUNCTION Muestra_Collec_Publi(_NAME_COLLEC VARCHAR(100))
RETURNS TABLE(TITLE VARCHAR(100),FIRST_NAME VARCHAR(70),SECOND_NAME VARCHAR(70),
			  FIRST_LAST_NAME VARCHAR(100),SECOND_LAST_NAME VARCHAR(100),
			  PUBLI_DATE DATE,NAME_INSTI VARCHAR(150),NAME_COLLEC VARCHAR(100))
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN QUERY
	SELECT Publication_.TITLE, 
		   Author.FIRST_NAME, Author.SECOND_NAME, Author.FIRST_LAST_NAME, SECOND_LAST_NAME,
		   Publication_.PUBLI_DATE, 
		   Institution.NAME_INSTI, Collection.NAME_COLLEC
	FROM Publication_, Institution, Collection, Publi_Collec, Publi_Author
	WHERE Collection.NAME_COLLEC = _NAME_COLLEC AND
		  Collection.ID = Publi_Collec.COLLEC_ID AND
		  Publication_.ID = Publi_Collec.PUBLI_ID AND
		  Author.ID = Publi_Author.AUTHOR_ID AND
		  Publication_.ID = Publi_Author.PUBLI_ID;
END;
$$

CREATE OR REPLACE FUNCTION Get_PubliID(_TITLE VARCHAR(100))
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
	PUBLI_ID INT;
BEGIN
	SELECT ID INTO PUBLI_ID
	FROM Publication_
	WHERE TITLE = _TITLE;
END;
$$