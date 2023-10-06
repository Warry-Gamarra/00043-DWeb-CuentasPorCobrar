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
        Posgrado,
        SegundaEspecialidad,
        Residentado
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

    public enum TipoSeccionArchivo
    {
        Cabecera_Resumen = 1,
        Detalle_Recaudacion = 2
    }

    public enum TipoEstudio
    {
        Pregrado,
        Posgrado,
        Segunda_Especialidad,
        Residentado
    }

    public enum CondicionPago
    {
        Correcto = 131,
        Extorno = 132,
        DoblePago = 135,
        ObligacionNoExiste = 136,
        PagoDesenlazado = 137,
        NoCampoMora = 142
    }

    public enum Periodos
    {
        Anual = 15,
        Semestral1 = 19,
        Semestral2 = 20
    }
}
