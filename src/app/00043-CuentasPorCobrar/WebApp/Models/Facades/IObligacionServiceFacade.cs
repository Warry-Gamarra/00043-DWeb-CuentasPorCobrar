using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models.Facades
{
    public interface IObligacionServiceFacade
    {
        Response Generar_Obligaciones(int anio, int periodo, TipoEstudio tipoEstudio, string codDependencia, int currentUserID);

        Response Generar_Obligaciones_PorAlumno(int anio, int periodo, string codAlu, string codRc, string nivel, int currentUserID);

        List<ObligacionDetalleModel> Obtener_DetallePago(int anio, int periodo, string codAlu, string codRc);

        List<CuotaPagoModel> Obtener_CuotasPago(int anio, int periodo, string codAlu, string codRc);

        List<CuotaPagoModel> Obtener_CuotasPago_X_Proceso(int anio, int? periodo, TipoEstudio tipoEstudio, string codDependencia);

        IEnumerable<CtaDepoProcesoModel> Obtener_CtaDeposito_X_Periodo(int anio, int? periodo, TipoEstudio tipoEstudio);

        CuotaPagoModel Obtener_CuotaPago(int obligacionID);

        List<ObligacionDetalleModel> Obtener_DetalleObligacion_X_Obligacion(int idObligacion);

        ObligacionDetalleModel Obtener_DetalleObligacion_X_ID(int idObligacionDet);

        Response ActualizarMontoObligaciones(int obligacionAluDetID, decimal monto, int tipoDocumento, string documento, int userID);

        Response AnularObligacion(int obligacionID, int currentUserID);
    }
}