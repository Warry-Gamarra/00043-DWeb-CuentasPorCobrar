using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public interface ITransferenciaInformacion
    {
        MemoryStream GenerarInformacionObligaciones(int anio, int? periodo, TipoEstudio? tipoEstudio, string dependencia);

        string NombreArchivoGenerado();

        void RecepcionarInformacionPagos();

    }
}
