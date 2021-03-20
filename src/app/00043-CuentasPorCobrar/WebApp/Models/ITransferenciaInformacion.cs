using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public interface ITransferenciaInformacion
    {
        byte[] GenerarInformacionObligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string facultad, DateTime? fechaDesde, DateTime? fechaHasta);

        void RecepcionarInformacionPagos();
    }
}