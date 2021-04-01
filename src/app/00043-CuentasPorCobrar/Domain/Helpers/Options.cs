﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Helpers
{
    public enum SaveOption
    {
        Insert,
        Update
    }

    public enum TipoAlumno
    {
        Pregrado,
        Posgrado
    }

    public enum TipoArchivoAlumno
    {
        Matricula,
        MultaNoVotar
    }

    public enum TipoObligacion
    {
        Matricula,
        OtrosPagos
    }
}
