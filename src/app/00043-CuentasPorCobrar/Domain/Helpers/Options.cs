using System;
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

    public enum TipoPago
    {
        Obligacion,
        Tasa
    }

    public enum TipoArchivoEntFinan
    {
        Datos_Alumno = 1,
        Deuda_Obligaciones = 2,
        Recaudacion_Obligaciones = 3,
        Recaudacion_Tasas = 4
    }

}
