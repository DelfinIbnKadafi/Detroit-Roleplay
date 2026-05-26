CREATE TABLE Pemain (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nama VARCHAR(64) NOT NULL,
    verified INT DEFAULT 0,
    kode INT,
    sandi VARCHAR(256),
    gender INT
);