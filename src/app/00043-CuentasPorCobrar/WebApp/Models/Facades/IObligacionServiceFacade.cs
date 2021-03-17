using Domain.DTO;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.Facades
{
    public interface IObligacionServiceFacade
    {
        Response Generar_Obligaciones_Pregrado(int anio, int periodo, string codFacultad, int currentUserID);

        Response Generar_Obligaciones_Posgrado(int anio, int periodo, int currentUserID);

        Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, int currentUserID);

        List<ObligacionDetalleModel> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc);

        List<CuotaPagoModel> Obtener_CuotaPago(int anio, int periodo, string codAlu, string codRc);

        List<CuotaPagoModel> Obtener_CuotasPago_X_Proceso(int anio, int periodo, int tipoAlumno, int nivel);
    }
}