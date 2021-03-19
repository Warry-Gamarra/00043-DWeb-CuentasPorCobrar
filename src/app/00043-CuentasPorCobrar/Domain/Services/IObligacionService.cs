using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IObligacionService
    {
        Response Generar_Obligaciones_Pregrado(int anio, int periodo, string codFacultad, int currentUserID);

        Response Generar_Obligaciones_Posgrado(int anio, int periodo, int currentUserID);

        Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID);

        IEnumerable<ObligacionDetalleDTO> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc);

        IEnumerable<CuotaPagoDTO> Obtener_CuotasPago(int anio, int periodo, string codAlu, string codRc);

        IEnumerable<CuotaPagoDTO> Obtener_CuotasPago_X_Proceso(int anio, int periodo, int tipoAlumno, int nivel);
    }
}
