CREATE TABLE Result_Inspeccion_senderos (
    ID_formularios INT NOT NULL,
    Num_sendero INT NOT NULL,
    Fecha_Inspe_real DATE,
    Cod_estado INT,
    Comentarios VARCHAR(255),
    Duracion_Insp INT,

    CONSTRAINT PK_Result_Inspeccion_senderos
        PRIMARY KEY (ID_formularios, Num_sendero),

    CONSTRAINT FK_Result_Inspeccion_senderos_Inspeccion
        FOREIGN KEY (ID_formularios, Num_sendero)
        REFERENCES Inspeccion_senderos (ID_formularios, Num_sendero),

    CONSTRAINT FK_Result_Inspeccion_senderos_Estados
        FOREIGN KEY (Cod_estado)
        REFERENCES Estados (Cod_estado)
);